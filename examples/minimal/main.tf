module "rds_mysql" {
  source             = "../../"
  identifier         = "prod-db"
  name               = "prodDb"
  engine_version     = "8.0.40"
  instance_class     = "db.t4g.micro"
  allocated_storage  = 50
  username           = local.creds.username
  password           = local.creds.password
  subnet_ids         = module.vpc.public_subnet_ids
  vpc_id             = module.vpc.vpc_id
  source_cidr_blocks = [module.vpc.vpc_cidr_block]
}

data "aws_secretsmanager_secret_version" "db" {
  secret_id = "prod-db-credentials"
}

resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.ec2_instance_type
  key_name               = var.key_pair_name
  subnet_id              = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    rds_endpoint = module.rds_mysql.db_instance_endpoint,
    db_username  = local.creds.username,
    db_password  = local.creds.password
  }))

  tags = {
    Name = "${var.identifier}-app-server"
  }
}

# You also need the security group for this EC2 instance
resource "aws_security_group" "ec2" {
  name_prefix = "${var.identifier}-ec2-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this in production
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# And the data source to find the latest Amazon Linux AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

module "vpc" {
  source                    = "git::https://github.com/tmknom/terraform-aws-vpc.git?ref=tags/2.0.1"
  cidr_block                = local.cidr_block
  name                      = "vpc-rds-mysql"
  public_subnet_cidr_blocks = [cidrsubnet(local.cidr_block, 8, 0), cidrsubnet(local.cidr_block, 8, 1)]
  public_availability_zones = data.aws_availability_zones.available.names
}

locals {
  cidr_block = "10.255.0.0/16"
  # Convert the JSON string returned by Secrets Manager into a Terraform map
  creds = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)
}

data "aws_availability_zones" "available" {}
