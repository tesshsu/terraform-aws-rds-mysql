variable "identifier" {
  type        = string
  description = "Database identifier"
}

variable "engine_version" {
  type        = string
  description = "MySQL engine version"
  default     = "8.0.35"
}

variable "instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  type        = number
  description = "Allocated storage in gibibytes"
  default     = 50
}

variable "username" {
  type        = string
  description = "Master username for the DB instance"
  default     = "admin"
}

variable "password" {
  type        = string
  description = "Master password for the DB instance"
}

variable "ec2_instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_pair_name" {
  type        = string
  description = "AWS key pair name for SSH access"
}
