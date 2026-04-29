region                 = "ap-south-1"
cross_account_role_arn = "arn:aws:iam::118402680584:role/TerraformCrossAccountRole-Krishal-AWS"
target_account_id      = "118402680584"

name_prefix = "tf-test"
owner       = "krishal"
project     = "terraform-practical-test"
environment = "dev"

# VPC
vpc_cidr             = "10.0.0.0/16"
azs                  = ["ap-south-1a", "ap-south-1b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

# EC2
instance_type     = "t2.micro"
key_name          = "ayush-terraform-assignment"
ssh_allowed_cidrs = ["0.0.0.0/0"]

# RDS
db_name     = "appdb"
db_username = "admin"
# db_password  ← set via TF_VAR_db_password environment variable

# CI/CD
github_owner  = "krishaldankhara-growexxer"
github_repo   = "terraform-practical-test"
github_branch = "main"
