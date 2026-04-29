data "aws_caller_identity" "current" {}

locals {
  common_tags = {
    owner       = var.owner
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}

module "vpc" {
  source = "../modules/vpc"

  vpc_cidr             = var.vpc_cidr
  vpc_name             = "terraform-main-vpc"
  name_prefix          = var.name_prefix
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.common_tags
}

module "alb" {
  source = "../modules/alb"

  name_prefix       = var.name_prefix
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  tags              = local.common_tags
}

module "ec2" {
  source = "../modules/ec2"

  name_prefix           = var.name_prefix
  vpc_id                = module.vpc.vpc_id
  public_subnet_id      = module.vpc.public_subnet_ids[0]
  alb_security_group_id = module.alb.alb_security_group_id
  ssh_allowed_cidrs     = var.ssh_allowed_cidrs
  instance_type         = var.instance_type
  key_name              = var.key_name
  welcome_message       = "Terraform Practical Test Completed"
  tags                  = local.common_tags
}

module "asg" {
  source = "../modules/asg"

  name_prefix               = var.name_prefix
  instance_type             = var.instance_type
  key_name                  = var.key_name
  ec2_security_group_id     = module.ec2.security_group_id
  iam_instance_profile_name = module.ec2.iam_instance_profile_name
  public_subnet_ids         = module.vpc.public_subnet_ids
  target_group_arn          = module.alb.target_group_arn
  min_size                  = 1
  desired_capacity          = 1
  max_size                  = 2
  welcome_message           = "Terraform Practical Test Completed"
  tags                      = local.common_tags
}

module "rds" {
  source = "../modules/rds"

  name_prefix           = var.name_prefix
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  app_security_group_id = module.ec2.security_group_id
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  tags                  = local.common_tags
}

module "cicd" {
  source = "../modules/cicd"

  name_prefix   = var.name_prefix
  account_id    = data.aws_caller_identity.current.account_id
  github_owner  = var.github_owner
  github_repo   = var.github_repo
  github_branch = var.github_branch
  tags          = local.common_tags
}

module "cloudwatch" {
  source = "../modules/cloudwatch"

  name_prefix             = var.name_prefix
  region                  = var.region
  asg_name                = module.asg.asg_name
  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix
  db_instance_id          = module.rds.db_instance_id
  tags                    = local.common_tags
}

module "lambda" {
  source = "../modules/lambda"

  name_prefix = var.name_prefix
  tags        = local.common_tags
}

resource "aws_s3_bucket" "tf_state" {
  bucket        = "tf-state-krishal-ap-south-1"
  force_destroy = false

  tags = merge(local.common_tags, {
    Name = "tf-state-krishal-ap-south-1"
  })
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
