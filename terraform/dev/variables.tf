# ---------- Provider / Cross-Account ----------
variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "cross_account_role_arn" {
  description = "ARN of TerraformCrossAccountRole in the target account"
  type        = string
}

variable "target_account_id" {
  description = "AWS Account ID of the target account (Ayush's account)"
  type        = string
}

# ---------- Project Metadata ----------
variable "name_prefix" {
  description = "Short prefix used in all resource names"
  type        = string
  default     = "tf-test"
}

variable "owner" {
  description = "Owner tag value"
  type        = string
  default     = "krishal"
}

variable "project" {
  description = "Project tag value"
  type        = string
  default     = "terraform-practical-test"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# ---------- VPC ----------
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

# ---------- EC2 / ASG ----------
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of existing EC2 key pair (created manually)"
  type        = string
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to SSH into EC2"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ---------- RDS ----------
variable "db_password" {
  description = "RDS master password — set via TF_VAR_db_password env var, never in tfvars"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "admin"
}

# ---------- CI/CD ----------
variable "github_owner" {
  description = "GitHub username or org"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch"
  type        = string
  default     = "main"
}
