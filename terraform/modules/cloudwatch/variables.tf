variable "name_prefix" {
  description = "Prefix for dashboard name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the ALB (from alb module output)"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "ARN suffix of the target group (from alb module output)"
  type        = string
}

variable "db_instance_id" {
  description = "RDS DB instance identifier"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
