output "db_instance_address" {
  value = module.rds_mysql.db_instance_address
}

output "db_instance_arn" {
  value = module.rds_mysql.db_instance_arn
}

output "db_instance_allocated_storage" {
  value = module.rds_mysql.db_instance_allocated_storage
}

output "db_instance_availability_zone" {
  value = module.rds_mysql.db_instance_availability_zone
}

output "db_instance_backup_retention_period" {
  value = module.rds_mysql.db_instance_backup_retention_period
}

output "db_instance_backup_window" {
  value = module.rds_mysql.db_instance_backup_window
}

output "db_instance_ca_cert_identifier" {
  value = module.rds_mysql.db_instance_ca_cert_identifier
}

output "db_instance_endpoint" {
  value = module.rds_mysql.db_instance_endpoint
}

output "db_instance_engine" {
  value = module.rds_mysql.db_instance_engine
}

output "db_instance_engine_version" {
  value = module.rds_mysql.db_instance_engine_version
}

output "db_instance_hosted_zone_id" {
  value = module.rds_mysql.db_instance_hosted_zone_id
}

output "db_instance_id" {
  value = module.rds_mysql.db_instance_id
}

output "db_instance_class" {
  value = module.rds_mysql.db_instance_class
}

output "db_instance_maintenance_window" {
  value = module.rds_mysql.db_instance_maintenance_window
}

output "db_instance_multi_az" {
  value = module.rds_mysql.db_instance_multi_az
}

output "db_instance_name" {
  value = module.rds_mysql.db_instance_name
}

output "db_instance_port" {
  value = module.rds_mysql.db_instance_port
}

output "db_instance_resource_id" {
  value = module.rds_mysql.db_instance_resource_id
}

output "db_instance_status" {
  value = module.rds_mysql.db_instance_status
}

output "db_instance_storage_encrypted" {
  value = module.rds_mysql.db_instance_storage_encrypted
}

output "db_instance_username" {
  value = module.rds_mysql.db_instance_username
}

output "db_option_group_id" {
  value = module.rds_mysql.db_option_group_id
}

output "db_option_group_arn" {
  value = module.rds_mysql.db_option_group_arn
}

output "db_parameter_group_id" {
  value = module.rds_mysql.db_parameter_group_id
}

output "db_parameter_group_arn" {
  value = module.rds_mysql.db_parameter_group_arn
}

output "db_subnet_group_id" {
  value = module.rds_mysql.db_subnet_group_id
}

output "db_subnet_group_arn" {
  value = module.rds_mysql.db_subnet_group_arn
}

output "security_group_id" {
  value = module.rds_mysql.security_group_id
}

output "security_group_arn" {
  value = module.rds_mysql.security_group_arn
}

output "security_group_vpc_id" {
  value = module.rds_mysql.security_group_vpc_id
}

output "security_group_owner_id" {
  value = module.rds_mysql.security_group_owner_id
}

output "security_group_name" {
  value = module.rds_mysql.security_group_name
}

output "security_group_description" {
  value = module.rds_mysql.security_group_description
}

output "security_group_ingress" {
  value = module.rds_mysql.security_group_ingress
}

output "security_group_egress" {
  value = module.rds_mysql.security_group_egress
}

output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "ec2_ssh_command" {
  description = "SSH command to connect to EC2"
  value       = "ssh -i ${var.key_pair_name}.pem ec2-user@${aws_instance.app_server.public_ip}"
}

output "rds_endpoint" {
  description = "RDS MySQL endpoint"
  value       = module.rds_mysql.this_db_instance_endpoint
}

output "todo_app_url" {
  description = "URL for todo application"
  value       = "http://${aws_instance.app_server.public_ip}"
}

