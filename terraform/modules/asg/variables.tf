variable "name_prefix" {
  description = "Prefix for ASG resource names"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "ec2_security_group_id" {
  description = "Security group ID for ASG instances"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name to attach to launch template"
  type        = string
}

variable "public_subnet_ids" {
  description = "Subnets for the ASG (placed in public for ALB target reachability)"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ALB target group ARN"
  type        = string
}

variable "min_size" {
  description = "Minimum capacity"
  type        = number
  default     = 1
}

variable "desired_capacity" {
  description = "Desired capacity"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum capacity"
  type        = number
  default     = 2
}

variable "welcome_message" {
  description = "Web page text"
  type        = string
  default     = "Terraform Practical Test Completed"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
