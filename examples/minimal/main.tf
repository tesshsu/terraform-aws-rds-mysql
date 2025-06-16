# Fetch secrets from AWS Secrets Manager
data "aws_secretsmanager_secret" "db_credentials" {
  name = "aurora-hipaa-credentials"
}

data "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = data.aws_secretsmanager_secret.db_credentials.id
}

# Parse the secret JSON to extract username and password
locals {
  db_credentials = jsondecode(data.aws_secretsmanager_secret_version.db_credentials_version.secret_string)
  db_username    = local.db_credentials.username
  db_password    = local.db_credentials.password
}

# Aurora Serverless v2 module
module "aurora_mysql" {
  source            = "../../"
  identifier        = var.identifier
  name              = var.name
  engine            = "aurora-mysql"
  engine_version    = var.engine_version
  instance_class    = "db.serverless"  # Aurora Serverless v2
  username          = local.db_username
  password          = local.db_password
  subnet_ids        = module.vpc.private_subnet_ids  # Use private subnets for security
  vpc_id            = module.vpc.vpc_id
  source_cidr_blocks = [module.vpc.vpc_cidr_block]

  # HIPAA-specific configurations
  storage_encrypted      = true
  kms_key_id             = aws_kms_key.aurora_key.arn
  enabled_cloudwatch_logs_exports = ["audit", "error", "general"]
  backup_retention_period = 90  # HIPAA requires 90 days
  skip_final_snapshot    = false
  deletion_protection    = true
  apply_immediately      = false

  # Aurora Serverless v2 scaling
  serverlessv2_scaling_configuration = {
    min_capacity = 0.5  # Minimum ACUs
    max_capacity = 16   # Maximum ACUs
  }

  # Enforce SSL/TLS for data in transit
  parameter_group_name   = aws_db_parameter_group.hipaa_params.name
}

# Create a KMS key for encryption
resource "aws_kms_key" "aurora_key" {
  description             = "KMS key for Aurora HIPAA encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

resource "aws_kms_alias" "aurora_key_alias" {
  name          = "alias/aurora-hipaa-key"
  target_key_id = aws_kms_key.aurora_key.key_id
}

# Custom parameter group to enforce SSL
resource "aws_db_parameter_group" "hipaa_params" {
  name        = "hipaa-aurora-params"
  family      = "aurora-mysql8.0"  # Match Aurora MySQL family
  description = "HIPAA-compliant parameter group"

  parameter {
    name  = "require_ssl"
    value = "1"  # Enforce SSL connections
  }
}

# EC2 instance setup (unchanged, but ensure it uses private subnet or VPC access)
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.ec2_instance_type
  key_name               = var.key_pair_name
  subnet_id              = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    rds_endpoint = module.aurora_mysql.cluster_endpoint,
    db_username  = local.db_username,
    db_password  = local.db_password
  }))

  tags = {
    Name = "${var.identifier}-app-server"
  }
}

# Security group for EC2 (restrict access)
resource "aws_security_group" "ec2" {
  name_prefix = "${var.identifier}-ec2-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_Office_IP/32"]  # Replace with your IP or VPN
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for Aurora
resource "aws_security_group" "aurora" {
  name_prefix = "${var.identifier}-aurora-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 3306  # Aurora MySQL port
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Associate Aurora security group with the module
module "aurora_mysql" {
  # ... other args ...
  vpc_security_group_ids = [aws_security_group.aurora.id]
}

# VPC module (ensure private subnets)
module "vpc" {
  source                    = "git::https://github.com/tmknom/terraform-aws-vpc.git?ref=tags/2.0.1"
  cidr_block                = local.cidr_block
  name                      = "vpc-aurora-mysql"
  public_subnet_cidr_blocks = [cidrsubnet(local.cidr_block, 8, 0), cidrsubnet(local.cidr_block, 8, 1)]
  private_subnet_cidr_blocks = [cidrsubnet(local.cidr_block, 8, 2), cidrsubnet(local.cidr_block, 8, 3)]
  public_availability_zones = data.aws_availability_zones.available.names
}

locals {
  cidr_block = "10.255.0.0/16"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_availability_zones" "available" {}