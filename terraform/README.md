# Terraform Practical Test — Cross-Account AWS Infrastructure

A fully automated AWS infrastructure deployment using Terraform, provisioned cross-account with a CI/CD pipeline, CloudWatch monitoring, and a Lambda-based start/stop scheduler.

---

## Architecture Overview

```
Krishal's Account (Terraform runs here)
  └── Assumes role ──► TerraformCrossAccountRole in Ayush's Account
                            │
                            ▼
                   ┌────────────────────────────────────────┐
                   │          Ayush's AWS Account            │
                   │                                        │
                   │  VPC 10.0.0.0/16 (terraform-main-vpc) │
                   │                                        │
                   │  Public Subnets (1a, 1b)               │
                   │    └── Internet-facing ALB (port 80)   │
                   │                                        │
                   │  Private Subnets (1a, 1b)              │
                   │    └── EC2 t2.micro via ASG            │
                   │    └── RDS MySQL db.t3.micro           │
                   │                                        │
                   │  CodePipeline ─► CodeBuild ─► CodeDeploy│
                   │  CloudWatch Dashboard                   │
                   │  Lambda Start/Stop Scheduler (EventBridge)│
                   └────────────────────────────────────────┘
```

---

## Folder Structure

```
terraform/
├── modules/
│   ├── vpc/          # VPC, subnets, IGW, NAT, route tables
│   ├── ec2/          # EC2, IAM role, security group, user-data
│   ├── alb/          # ALB, target group, listener
│   ├── asg/          # Launch template, ASG, scaling policies
│   ├── rds/          # RDS MySQL, DB subnet group, security group
│   ├── cicd/         # CodePipeline, CodeBuild, CodeDeploy, CodeStar connection
│   ├── cloudwatch/   # CloudWatch dashboard and alarms
│   └── lambda/       # Start/Stop Lambda functions + EventBridge rules
├── dev/
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── outputs.tf
│   ├── provider.tf
│   ├── backend.tf
│   └── cicd_assets/  # buildspec.yml, appspec.yml, deploy scripts
├── submission/
│   └── screenshots/  # Deployment proof screenshots (task-by-task)
└── README.md         ← you are here
```

---

## Prerequisites

Before starting, make sure you have the following ready:

| Requirement | Details |
| --- | --- |
| AWS CLI | Installed and configured with Krishal's credentials |
| Terraform | v1.6 or higher |
| Git | For cloning and pushing to GitHub |
| EC2 Key Pair | Created manually in Ayush's account — save the `.pem` file |
| GitHub repo | This repo, with `buildspec.yml` and `appspec.yml` present |
| Cross-account IAM role | `TerraformCrossAccountRole` in Ayush's account (Step 1) |

---

## Step-by-Step Deployment Guide

---

### Step 1 — Create Cross-Account IAM Role (One-Time, in Ayush's Account)

This role allows Terraform running in Krishal's account to provision resources in Ayush's account.

1. Log in to **Ayush's AWS Console**
2. Go to **IAM → Roles → Create Role**
3. Select **"Another AWS account"** as the trusted entity type
4. Enter **Krishal's AWS Account ID**
5. Attach policy: **AdministratorAccess**
6. Name the role: `TerraformCrossAccountRole`
7. Create the role and copy the **Role ARN**

The Role ARN will look like:

```
arn:aws:iam::118402680584:role/TerraformCrossAccountRole
```

---

### Step 2 — Set Up Terraform Server (EC2 in Krishal's Account)

Launch a `t2.micro` Amazon Linux 2 EC2 in Krishal's account and SSH into it.

Install Terraform:
```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum install -y terraform
```

Install Git and Unzip:
```bash
sudo yum install -y git unzip
```

Verify the setup:
```bash
terraform version
aws sts get-caller-identity
```

Clone the repository:
```bash
git clone https://github.com/krishaldankhara-growexxer/terraform-practical-test.git
cd terraform-practical-test
```

---

### Step 3 — Bootstrap Remote Backend (S3 + DynamoDB)

The S3 bucket and DynamoDB table for Terraform remote state must exist before running `terraform init`.

Run these commands in Ayush's account (via cross-account CLI or Ayush runs them directly):

```bash
aws s3api create-bucket \
  --bucket tf-state-krishal-ayush-ap-south-1 \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

aws s3api put-bucket-versioning \
  --bucket tf-state-krishal-ayush-ap-south-1 \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket tf-state-krishal-ayush-ap-south-1 \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

aws s3api put-public-access-block \
  --bucket tf-state-krishal-ayush-ap-south-1 \
  --public-access-block-configuration \
  '{"BlockPublicAcls":true,"IgnorePublicAcls":true,"BlockPublicPolicy":true,"RestrictPublicBuckets":true}'

aws dynamodb create-table \
  --table-name tf-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-south-1
```

---

### Step 4 — Configure Variables and Initialize

```bash
cd terraform/dev
```

Open `terraform.tfvars` and fill in your values:

```hcl
region                 = "ap-south-1"
cross_account_role_arn = "arn:aws:iam::YOUR_AYUSH_ACCOUNT_ID:role/TerraformCrossAccountRole"
target_account_id      = "YOUR_AYUSH_ACCOUNT_ID"

name_prefix = "tf-test"
owner       = "krishal"
project     = "terraform-practical-test"
environment = "dev"

vpc_cidr             = "10.0.0.0/16"
azs                  = ["ap-south-1a", "ap-south-1b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

instance_type     = "t2.micro"
key_name          = "your-keypair-name"
ssh_allowed_cidrs = ["0.0.0.0/0"]

db_name     = "appdb"
db_username = "admin"

github_owner  = "your-github-username"
github_repo   = "terraform-practical-test"
github_branch = "main"
```

Set the DB password via environment variable (never store it in tfvars):
```bash
export TF_VAR_db_password='YourStrongPassword123!'
```

Initialize Terraform:
```bash
terraform init
```

---

### Step 5 — Deploy All Infrastructure

```bash
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

This deploys VPC, EC2, ALB, ASG, RDS, CI/CD pipeline, CloudWatch dashboard, and Lambda scheduler in a single apply. RDS provisioning takes 5–10 minutes — this is expected.

After apply, check the outputs:
```bash
terraform output alb_dns_name
terraform output cloudwatch_dashboard_name
terraform output pipeline_name
```

Open the ALB DNS in a browser — you should see **"Terraform Practical Test"** served by Nginx.

---

### Step 6 — Authorize GitHub Connection and Trigger Pipeline

The CodeStar GitHub connection is created by Terraform but must be authorized manually once:

1. AWS Console → **Developer Tools → Settings → Connections**
2. Find `tf-test-github-conn` (status: Pending)
3. Click **Update pending connection** → authorize against your GitHub account
4. Go to **CodePipeline → tf-test-pipeline** → click **Release change**

The pipeline will pull from GitHub → build via CodeBuild → deploy via CodeDeploy to the EC2 instance.

---

### Step 7 — Test Lambda Scheduler (Manual Invocation)

The Lambda functions stop and start EC2 and RDS on a schedule (8 PM IST stop / 8 AM IST start via EventBridge).

To test manually:

```bash
# Simulate 8 PM stop
aws lambda invoke \
  --function-name tf-test-scheduler-stop \
  --region ap-south-1 \
  /tmp/lambda_stop_response.json

cat /tmp/lambda_stop_response.json

# Simulate 8 AM start
aws lambda invoke \
  --function-name tf-test-scheduler-start \
  --region ap-south-1 \
  /tmp/lambda_start_response.json

cat /tmp/lambda_start_response.json
```

Verify in the AWS Console that EC2 and RDS transition to stopped/available state after invocation.

---

### Step 8 — Tear Down

When done, destroy all resources to avoid ongoing costs:

```bash
terraform destroy -auto-approve
```

> NAT Gateway and ALB are the main cost drivers — destroy promptly when not in use.

---

## Cost Estimate

| Service | Type | Approx. Monthly Cost (ap-south-1) |
| --- | --- | --- |
| EC2 t2.micro | Free Tier eligible | $0 |
| RDS MySQL db.t3.micro | Free Tier eligible | $0 |
| NAT Gateway | ~$0.045/hr + data transfer | ~$32 |
| ALB | ~$0.016/hr + LCU charges | ~$12 |
| S3 state bucket | Minimal storage | <$1 |
| DynamoDB lock table | PAY_PER_REQUEST | <$1 |
| Lambda | Free Tier (1M invocations/month) | $0 |
| CloudWatch | Free Tier metrics | $0 |
| **Total** | | **~$45/month** |

NAT Gateway is the biggest cost driver. Destroy when not actively testing.

---

## Troubleshooting

### `terraform init` fails — backend bucket not found

Create the S3 bucket first (Step 3), then re-run `terraform init`.

### Cross-account authentication fails

```bash
aws sts assume-role \
  --role-arn "arn:aws:iam::AYUSH_ACCOUNT_ID:role/TerraformCrossAccountRole" \
  --role-session-name test
```

If this fails, verify the trust policy in Ayush's account includes Krishal's AWS account ID.

### RDS takes too long

RDS provisioning takes 5–10 minutes. Wait for status `available` before proceeding.

### CodePipeline stuck at Source stage

The GitHub connection needs manual authorization in the AWS Console. See Step 6.

### Lambda invoke — function not found

Ensure `terraform apply` completed successfully and the Lambda functions exist in the correct region (`ap-south-1`).

### EC2 shows unhealthy in Target Group

Wait 2–3 minutes for the user-data script (Nginx install) to complete, then check again.

---

## Quick Reference

```bash
terraform init        # Initialize providers and backend
terraform validate    # Check syntax
terraform plan        # Preview changes
terraform apply       # Deploy all resources
terraform output      # Show outputs (ALB URL, dashboard name, pipeline name)
terraform destroy     # Tear down everything
```

```bash
# Set DB password before every apply/plan
export TF_VAR_db_password='YourStrongPassword123!'
```
