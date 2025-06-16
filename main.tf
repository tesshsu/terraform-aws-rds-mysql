resource "aws_rds_cluster" "default" {
  engine                 = "aurora-mysql"
  engine_version         = var.engine_version
  cluster_identifier     = var.identifier
  database_name          = var.name
  master_username        = var.username
  master_password        = var.password
  vpc_security_group_ids = [aws_security_group.default.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
  storage_encrypted      = var.storage_encrypted
  kms_key_id             = var.kms_key_id
  backup_retention_period = var.backup_retention_period
  deletion_protection    = var.deletion_protection
  skip_final_snapshot    = var.skip_final_snapshot
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  apply_immediately      = var.apply_immediately

  # Aurora Serverless v2 configuration
  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 16
  }
}

resource "aws_rds_cluster_instance" "default" {
  cluster_identifier  = aws_rds_cluster.default.id
  engine              = aws_rds_cluster.default.engine
  engine_version      = aws_rds_cluster.default.engine_version
  instance_class      = var.instance_class
  identifier          = "${var.identifier}-instance"
  db_subnet_group_name = aws_db_subnet_group.default.name
  publicly_accessible = var.publicly_accessible
  storage_encrypted   = var.storage_encrypted
  kms_key_id          = var.kms_key_id
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_role_arn
  apply_immediately   = var.apply_immediately
}

# NOTE: Any modifications to the db_option_group are set to happen immediately as we default to applying immediately.
#
# https://www.terraform.io/docs/providers/aws/r/db_option_group.html
resource "aws_db_option_group" "default" {
  engine_name              = "mysql"
  name                     = var.identifier
  major_engine_version     = local.major_engine_version
  option_group_description = var.description

  tags = merge({ "Name" = var.identifier }, var.tags)
}

# If major_engine_version is unspecified, then calculate major_engine_version.
# Calculate from X.Y.Z(or X.Y) to X.Y, for example 5.7.21 is calculated 5.7.
locals {
  version_elements       = split(".", var.engine_version)
  major_version_elements = [local.version_elements[0], local.version_elements[1]]
  major_engine_version   = var.major_engine_version == "" ? join(".", local.major_version_elements) : var.major_engine_version
  security_group_name = "${var.identifier}-aurora-mysql"
}

# https://www.terraform.io/docs/providers/aws/r/db_parameter_group.html
resource "aws_db_parameter_group" "default" {
  name        = var.identifier
  family      = local.family
  description = var.description

  parameter {
    name         = "character_set_client"
    value        = var.character_set
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_connection"
    value        = var.character_set
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_database"
    value        = var.character_set
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_results"
    value        = var.character_set
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_server"
    value        = var.character_set
    apply_method = "immediate"
  }

  parameter {
    name         = "collation_connection"
    value        = var.collation
    apply_method = "immediate"
  }

  parameter {
    name         = "collation_server"
    value        = var.collation
    apply_method = "immediate"
  }

  parameter {
    name         = "time_zone"
    value        = var.time_zone
    apply_method = "immediate"
  }

  parameter {
    name         = "transaction_isolation"
    value        = var.transaction_isolation
    apply_method = "immediate"
  }

  tags = merge({ "Name" = var.identifier }, var.tags)
}

locals {
  family = "mysql${local.major_engine_version}"
}



# https://www.terraform.io/docs/providers/aws/r/db_subnet_group.html
resource "aws_db_subnet_group" "default" {
  name        = var.identifier
  subnet_ids  = var.subnet_ids
  description = var.description

  tags = merge({ "Name" = var.identifier }, var.tags)
}

# https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "default" {
  name   = local.security_group_name
  vpc_id = var.vpc_id

  tags = merge({ "Name" = local.security_group_name }, var.tags)
}

locals {
  security_group_name = "${var.identifier}-rds-mysql"
}

# https://www.terraform.io/docs/providers/aws/r/security_group_rule.html
resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  cidr_blocks       = var.source_cidr_blocks
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}

