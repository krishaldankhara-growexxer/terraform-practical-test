variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the EC2 instance will be deployed"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for the EC2 instance"
  type        = string
}

variable "alb_security_group_id" {
  description = "ALB Security Group ID allowed to reach the EC2 on port 80"
  type        = string
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the EC2 Key Pair (created manually)"
  type        = string
}

variable "welcome_message" {
  description = "Message shown on the web page"
  type        = string
  default     = "Terraform Practical Test Completed"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
