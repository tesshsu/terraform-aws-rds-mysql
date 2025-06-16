output "cluster_endpoint" {
  description = "Aurora cluster endpoint"
  value       = module.aurora_mysql.cluster_endpoint
}

output "cluster_arn" {
  value = module.aurora_mysql.cluster_arn
}

output "cluster_database_name" {
  value = module.aurora_mysql.cluster_database_name
}

output "cluster_engine" {
  value = module.aurora_mysql.cluster_engine
}

output "cluster_engine_version" {
  value = module.aurora_mysql.cluster_engine_version
}

output "cluster_id" {
  value = module.aurora_mysql.cluster_id
}

output "cluster_status" {
  value = module.aurora_mysql.cluster_status
}

output "security_group_id" {
  value = module.aurora_mysql.security_group_id
}

output "security_group_arn" {
  value = module.aurora_mysql.security_group_arn
}

output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "ec2_ssh_command" {
  description = "SSH command to connect to EC2"
  value       = "ssh -i ${var.key_pair_name}.pem ec2-user@${aws_instance.app_server.public_ip}"
}

output "aurora_endpoint" {
  description = "Aurora MySQL endpoint"
  value       = module.aurora_mysql.cluster_endpoint
}

output "todo_app_url" {
  description = "URL for todo application"
  value       = "http://${aws_instance.app_server.public_ip}"
}