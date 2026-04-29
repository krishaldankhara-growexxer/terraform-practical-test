# ---------- VPC ----------
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

# ---------- EC2 ----------
output "ec2_instance_id" {
  description = "Standalone EC2 instance ID"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Standalone EC2 public IP"
  value       = module.ec2.public_ip
}

# ---------- ALB ----------
output "alb_dns_name" {
  description = "ALB public DNS — open this in a browser to verify the web page"
  value       = module.alb.alb_dns_name
}

# ---------- ASG ----------
output "asg_name" {
  description = "Auto Scaling Group name"
  value       = module.asg.asg_name
}

# ---------- RDS ----------
output "rds_endpoint" {
  description = "RDS MySQL endpoint"
  value       = module.rds.db_endpoint
  sensitive   = true
}

output "rds_address" {
  description = "RDS hostname"
  value       = module.rds.db_address
  sensitive   = true
}

# ---------- CI/CD ----------
output "pipeline_name" {
  description = "CodePipeline name"
  value       = module.cicd.pipeline_name
}

output "github_connection_arn" {
  description = "GitHub CodeStar connection ARN — authorize this in the console"
  value       = module.cicd.github_connection_arn
}

# ---------- CloudWatch ----------
output "cloudwatch_dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = module.cloudwatch.dashboard_name
}

# ---------- Lambda ----------
output "lambda_stop_function" {
  description = "Name of the STOP Lambda"
  value       = module.lambda.stop_function_name
}

output "lambda_start_function" {
  description = "Name of the START Lambda"
  value       = module.lambda.start_function_name
}

# ---------- State Backend ----------
output "tf_state_bucket" {
  description = "S3 bucket storing Terraform state"
  value       = aws_s3_bucket.tf_state.bucket
}