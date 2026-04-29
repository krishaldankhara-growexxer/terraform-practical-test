variable "name_prefix" {
  description = "Prefix for RDS resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs (the DB will live here)"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "Security group of the app tier allowed to connect on 3306"
  type        = string
}

variable "engine_version" {
  description = "MySQL engine version"
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Master password (use TF_VAR_db_password env var)"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
