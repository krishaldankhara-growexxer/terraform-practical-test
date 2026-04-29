# Terraform Practical Test — Cross-Account AWS Setup
**Intern:** Krishal | **Target Account:** Ayush's AWS account | **Region:** ap-south-1

---

## Architecture Overview

```
Krishal's Account (Terraform runs here)
  └── Assumes role ──► TerraformCrossAccountRole in Ayush's Account
                            │
                            ▼
                   ┌────────────────────────────────────────┐
                   │        Ayush's AWS Account              │
                   │                                        │
                   │  VPC 10.0.0.0/16 (terraform-main-vpc) │
                   │  ┌──────────────┐  ┌───────────────┐  │
                   │  │ Public Subnet│  │ Public Subnet │  │
                   │  │ ap-south-1a  │  │ ap-south-1b   │  │
                   │  │ 10.0.1.0/24 │  │ 10.0.2.0/24   │  │
                   │  └──────┬───────┘  └───────┬───────┘  │
                   │         │   ALB (port 80)   │          │
                   │  ┌──────▼───────────────────▼──────┐  │
                   │  │         Internet-facing ALB       │  │
                   │  └──────────────────┬───────────────┘  │
                   │                     │ ASG (t2.micro)   │
                   │  ┌──────────────────▼───────────────┐  │
                   │  │  Private Subnet  │ Private Subnet  │  │
                   │  │  ap-south-1a     │ ap-south-1b     │  │
                   │  │  10.0.3.0/24    │ 10.0.4.0/24    │  │
                   │  │       RDS MySQL (db.t3.micro)     │  │
                   │  └──────────────────────────────────┘  │
                   │                                        │
                   │  CodePipeline ─► CodeBuild ─► CodeDeploy│
                   │  CloudWatch Dashboard                   │
                   │  Lambda (Start/Stop Scheduler)          │
                   └────────────────────────────────────────┘
```

---

## Folder Structure

```
terraform/
├── modules/
│   ├── vpc/          # VPC, Subnets, IGW, NAT, Route Tables
│   ├── ec2/          # EC2 instance, IAM role, Security Group, user-data
│   ├── alb/          # ALB, Target Group, Listener
│   ├── asg/          # Launch Template, ASG, Scaling Policies
│   ├── rds/          # RDS MySQL, DB Subnet Group, Security Group
│   ├── cicd/         # CodePipeline, CodeBuild, CodeDeploy, CodeStar
│   ├── cloudwatch/   # CloudWatch Dashboard
│   └── lambda/       # Start/Stop Lambda + EventBridge rules
├── dev/
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── outputs.tf
│   ├── provider.tf
│   ├── backend.tf
│   ├── README.md
│   └── cicd_assets/  # buildspec.yml, appspec.yml, scripts/
└── README.md         ← you are here
```

---

## Prerequisites

1. **AWS CLI** installed and configured with Krishal's credentials
2. **Terraform** v1.6+ installed
3. **EC2 Key Pair** created manually in Ayush's account → save the `.pem` file
4. **GitHub repo** created and pushed with `buildspec.yml` + `appspec.yml`
5. **TerraformCrossAccountRole** created in Ayush's account (see Step 1)

---

## STEP-BY-STEP DEPLOYMENT GUIDE

---

### STEP 1 — Create Cross-Account IAM Role (Manual, in Ayush's Account)

**Done once by Ayush in his AWS Console:**

1. Log in to **Ayush's AWS Console**
2. Go to **IAM → Roles → Create Role**
3. Select **"Another AWS account"**
4. Enter **Krishal's AWS Account ID** as the trusted entity
5. Attach policy: **AdministratorAccess**
6. Role name: `TerraformCrossAccountRole`
7. Click **Create Role**
8. Copy the **Role ARN** — example: `arn:aws:iam::123456789012:role/TerraformCrossAccountRole`

> 📸 **SCREENSHOT** → Save as: `submission/screenshots/01_iam_setup/01_cross_account_role_created.png`
> 📸 **SCREENSHOT** → `submission/screenshots/01_iam_setup/02_role_trust_policy.png`

**Submit immediately:**
```bash
cd terraform
git add .
git commit -m "TASK-01: Cross-account IAM role created (screenshot in submission/)"
git push
```

---

### STEP 2 — Set Up Terraform Server (EC2 in Krishal's Account)

1. Launch a `t2.micro` Amazon Linux 2 EC2 in **Krishal's account** (any region)
2. Attach an instance role with these policies:
   - `sts:AssumeRole` on `arn:aws:iam::AYUSH_ACCOUNT_ID:role/TerraformCrossAccountRole`
   - Or use `aws configure` with Krishal's access keys
3. SSH into the EC2 and install tools:

```bash
# Install Terraform
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum install -y terraform

# Install git + unzip
sudo yum install -y git unzip

# Verify
terraform version
aws sts get-caller-identity   # Should show Krishal's account
```

4. Clone your repo:
```bash
git clone https://github.com/YOUR_USERNAME/terraform-practical-test.git
cd terraform-practical-test
```

> 📸 **SCREENSHOT** → `submission/screenshots/02_terraform_server/01_terraform_version.png`
> 📸 **SCREENSHOT** → `submission/screenshots/02_terraform_server/02_aws_sts_identity.png`

**Submit immediately:**
```bash
git add submission/
git commit -m "TASK-02: Terraform server set up (screenshots added)"
git push
```

---

### STEP 3 — Bootstrap Backend (S3 + DynamoDB) — One-Time Setup

The S3 bucket and DynamoDB table for remote state must exist before `terraform init` can use them.

**Option A — AWS CLI (fastest):**
```bash
# In Ayush's account (via cross-account CLI or Ayush runs this himself)
aws s3api create-bucket \
  --bucket tf-state-krishal-ayush-ap-south-1 \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

aws s3api put-bucket-versioning \
  --bucket tf-state-krishal-ayush-ap-south-1 \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket tf-state-krishal-ayush-ap-south-1 \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

aws s3api put-public-access-block \
  --bucket tf-state-krishal-ayush-ap-south-1 \
  --public-access-block-configuration '{"BlockPublicAcls":true,"IgnorePublicAcls":true,"BlockPublicPolicy":true,"RestrictPublicBuckets":true}'

aws dynamodb create-table \
  --table-name tf-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-south-1
```

**Option B:** `terraform apply` creates the S3 + DynamoDB resources in `dev/main.tf`, then migrate state to remote (see Troubleshooting below).

> 📸 **SCREENSHOT** → `submission/screenshots/03_backend/01_s3_bucket_created.png`
> 📸 **SCREENSHOT** → `submission/screenshots/03_backend/02_s3_versioning_enabled.png`
> 📸 **SCREENSHOT** → `submission/screenshots/03_backend/03_dynamodb_table_created.png`

**Submit immediately:**
```bash
git add submission/screenshots/03_backend/
git commit -m "TASK-03: Remote backend S3 + DynamoDB created (screenshots added)"
git push
```

---

### STEP 4 — Configure tfvars and Initialize

```bash
cd terraform/dev

# Edit terraform.tfvars — fill in:
#   cross_account_role_arn = "arn:aws:iam::AYUSH_ACCOUNT_ID:role/TerraformCrossAccountRole"
#   target_account_id      = "AYUSH_ACCOUNT_ID"
#   key_name               = "your-keypair-name"
#   github_owner           = "your-github-username"
#   github_repo            = "terraform-practical-test"
nano terraform.tfvars

# Set the DB password via environment variable (NEVER in tfvars)
export TF_VAR_db_password='StrongPassword123!'

# Init with backend
terraform init
```

> 📸 **SCREENSHOT** → `submission/screenshots/03_backend/04_terraform_init_success.png`

**Submit:**
```bash
git add submission/screenshots/03_backend/04_terraform_init_success.png
git commit -m "TASK-03: terraform init successful with remote backend"
git push
```

---

### STEP 5 — Plan and Apply (VPC, EC2, ALB, ASG, RDS)

```bash
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

This deploys everything in one apply. Watch the output — it takes ~15–20 minutes (RDS is the slowest).

After apply completes, note the outputs:
```bash
terraform output alb_dns_name
terraform output cloudwatch_dashboard_name
terraform output pipeline_name
```

---

### STEP 6 — Take Screenshots: VPC + Subnets

1. AWS Console → **VPC → Your VPCs** → find `terraform-main-vpc`

> 📸 `submission/screenshots/04_vpc/01_vpc_created.png`

2. VPC → **Subnets** → filter by `tf-test`

> 📸 `submission/screenshots/04_vpc/02_public_subnets.png`
> 📸 `submission/screenshots/04_vpc/03_private_subnets.png`

3. VPC → **Internet Gateways**

> 📸 `submission/screenshots/04_vpc/04_internet_gateway.png`

4. VPC → **NAT Gateways**

> 📸 `submission/screenshots/04_vpc/05_nat_gateway.png`

5. VPC → **Route Tables**

> 📸 `submission/screenshots/04_vpc/06_route_tables.png`

**Submit:**
```bash
git add submission/screenshots/04_vpc/
git commit -m "TASK-04: VPC infrastructure screenshots added"
git push
```

---

### STEP 7 — Take Screenshots: EC2, ALB, ASG

1. **EC2 → Instances** — show `tf-test-ec2` running

> 📸 `submission/screenshots/05_ec2_alb_asg/01_ec2_instance_running.png`

2. **EC2 → Load Balancers** — show `tf-test-alb`, state Active

> 📸 `submission/screenshots/05_ec2_alb_asg/02_alb_active.png`

3. Open ALB DNS in browser — must show **"Terraform Practical Test Completed"**

> 📸 `submission/screenshots/05_ec2_alb_asg/03_alb_url_working.png` ← **CRITICAL**

4. **EC2 → Target Groups** — show healthy targets

> 📸 `submission/screenshots/05_ec2_alb_asg/04_target_group_healthy.png`

5. **EC2 → Auto Scaling Groups** — show `tf-test-asg`, min/desired/max = 1/1/2

> 📸 `submission/screenshots/05_ec2_alb_asg/05_asg_details.png`

6. **EC2 → Launch Templates** — show `tf-test-lt`

> 📸 `submission/screenshots/05_ec2_alb_asg/06_launch_template.png`

7. **CloudWatch → Alarms** — show CPU high/low alarms

> 📸 `submission/screenshots/05_ec2_alb_asg/07_scaling_alarms.png`

**Submit:**
```bash
git add submission/screenshots/05_ec2_alb_asg/
git commit -m "TASK-05: EC2, ALB, ASG screenshots added — ALB URL working"
git push
```

---

### STEP 8 — Take Screenshots: RDS

1. **RDS → Databases** — show `tf-test-mysql`, status Available

> 📸 `submission/screenshots/06_rds/01_rds_instance_available.png`

2. Click the instance → show Configuration tab (engine, class, storage, private only)

> 📸 `submission/screenshots/06_rds/02_rds_configuration.png`

3. **Prove RDS connectivity** — SSH into the EC2 instance, then:

```bash
# On the EC2 instance:
sudo yum install -y mysql
mysql -h <rds_address_from_output> -u admin -p
# Enter the DB password when prompted
# Once in mysql prompt:
SHOW DATABASES;
```

> 📸 `submission/screenshots/06_rds/03_rds_connectivity_proof.png` ← **CRITICAL**

**Submit:**
```bash
git add submission/screenshots/06_rds/
git commit -m "TASK-06: RDS screenshots + connectivity proof added"
git push
```

---

### STEP 9 — Authorize GitHub Connection and Trigger Pipeline

1. AWS Console → **Developer Tools → Settings → Connections**
2. Find `tf-test-github-conn` (status: Pending)
3. Click **Update pending connection** → authorize against your GitHub
4. Go to **CodePipeline** → find `tf-test-pipeline`
5. Click **Release change** to trigger the first run

> 📸 `submission/screenshots/07_cicd/01_github_connection_active.png`
> 📸 `submission/screenshots/07_cicd/02_codepipeline_success.png` ← **CRITICAL**
> 📸 `submission/screenshots/07_cicd/03_codebuild_success.png`
> 📸 `submission/screenshots/07_cicd/04_codedeploy_success.png`

**Submit:**
```bash
git add submission/screenshots/07_cicd/
git commit -m "TASK-07: CodePipeline success screenshots added"
git push
```

---

### STEP 10 — Take Screenshots: CloudWatch Dashboard

1. **CloudWatch → Dashboards** → open `tf-test-dashboard`
2. Screenshot showing all widgets: EC2 CPU, Disk/Network, ALB Request Count, ALB Healthy Hosts, RDS CPU, RDS Free Storage, RDS Connections

> 📸 `submission/screenshots/08_cloudwatch/01_dashboard_full.png` ← **CRITICAL**
> 📸 `submission/screenshots/08_cloudwatch/02_ec2_cpu_widget.png`
> 📸 `submission/screenshots/08_cloudwatch/03_alb_widgets.png`
> 📸 `submission/screenshots/08_cloudwatch/04_rds_widgets.png`

**Submit:**
```bash
git add submission/screenshots/08_cloudwatch/
git commit -m "TASK-08: CloudWatch dashboard screenshots added"
git push
```

---

### STEP 11 — Test Lambda Scheduler (Manual Invocation)

```bash
# Test STOP function manually (simulates 8 PM IST)
aws lambda invoke \
  --function-name tf-test-scheduler-stop \
  --region ap-south-1 \
  submission/logs/lambda_stop_response.json

cat submission/logs/lambda_stop_response.json

# Test START function manually (simulates 8 AM IST)
aws lambda invoke \
  --function-name tf-test-scheduler-start \
  --region ap-south-1 \
  submission/logs/lambda_start_response.json

cat submission/logs/lambda_start_response.json
```

1. AWS Console → **Lambda → tf-test-scheduler-stop** → **Monitor** → **View logs in CloudWatch**

> 📸 `submission/screenshots/09_lambda/01_stop_lambda_execution.png` ← **CRITICAL**
> 📸 `submission/screenshots/09_lambda/02_start_lambda_execution.png`
> 📸 `submission/screenshots/09_lambda/03_eventbridge_rules.png`
> 📸 `submission/screenshots/09_lambda/04_ec2_stopped_by_lambda.png`
> 📸 `submission/screenshots/09_lambda/05_rds_stopped_by_lambda.png`

**Submit:**
```bash
git add submission/logs/ submission/screenshots/09_lambda/
git commit -m "TASK-09: Lambda execution proof + CloudWatch logs added"
git push
```

---

### STEP 12 — Test terraform destroy

```bash
terraform plan -destroy
terraform destroy -auto-approve
```

> 📸 `submission/screenshots/10_destroy/01_terraform_destroy_complete.png` ← **CRITICAL**

**Submit:**
```bash
git add submission/screenshots/10_destroy/
git commit -m "TASK-10: terraform destroy completed successfully"
git push
```

---

## Submission Checklist

| # | Item | File / Proof | Status |
|---|------|-------------|--------|
| 1 | GitHub Repository | Repo URL | ⬜ |
| 2 | Terraform Code (all modules) | `terraform/` folder | ⬜ |
| 3 | VPC screenshot | `04_vpc/01_vpc_created.png` | ⬜ |
| 4 | Subnets screenshots | `04_vpc/02_03_subnets.png` | ⬜ |
| 5 | EC2 screenshot | `05_ec2_alb_asg/01_ec2_instance_running.png` | ⬜ |
| 6 | **ALB URL working** | `05_ec2_alb_asg/03_alb_url_working.png` | ⬜ |
| 7 | ASG screenshot | `05_ec2_alb_asg/05_asg_details.png` | ⬜ |
| 8 | S3 backend screenshot | `03_backend/01_s3_bucket_created.png` | ⬜ |
| 9 | DynamoDB table screenshot | `03_backend/03_dynamodb_table_created.png` | ⬜ |
| 10 | **RDS connectivity proof** | `06_rds/03_rds_connectivity_proof.png` | ⬜ |
| 11 | **CodePipeline success** | `07_cicd/02_codepipeline_success.png` | ⬜ |
| 12 | **CloudWatch dashboard** | `08_cloudwatch/01_dashboard_full.png` | ⬜ |
| 13 | **Lambda execution proof** | `09_lambda/01_stop_lambda_execution.png` | ⬜ |
| 14 | terraform destroy proof | `10_destroy/01_terraform_destroy_complete.png` | ⬜ |
| 15 | README with deployment steps | `README.md` | ⬜ |
| 16 | Cross-account IAM proof | `01_iam_setup/01_cross_account_role_created.png` | ⬜ |
| 17 | Cost estimation | `submission/COST_ESTIMATE.md` | ⬜ |

---

## Cost Estimation

| Service | Type | Cost (ap-south-1, ~30 days) |
|---------|------|-----------------------------|
| EC2 (t2.micro) | Free Tier (750 hrs/month) | $0 |
| RDS MySQL (db.t3.micro) | Free Tier (750 hrs/month) | $0 |
| NAT Gateway | ~$0.045/hr + data | ~$32/month |
| ALB | ~$0.008/LCU-hr + $0.016/hr | ~$12/month |
| S3 (state bucket) | Minimal | <$1/month |
| DynamoDB | PAY_PER_REQUEST | <$1/month |
| Lambda | Free Tier (1M invocations) | $0 |
| CloudWatch | Free Tier metrics | $0 |
| **Total** | | **~$45/month** |

> NAT Gateway is the biggest cost driver. Lambda + Lambda invocations are free tier.

---

## Troubleshooting

### terraform init fails (backend not found)
Create the S3 bucket manually first (see Step 3 Option A), then re-run `terraform init`.

### Cross-account auth fails
```bash
aws sts assume-role \
  --role-arn "arn:aws:iam::AYUSH_ACCOUNT_ID:role/TerraformCrossAccountRole" \
  --role-session-name test
```
If this fails, verify the trust policy in Ayush's account includes Krishal's account ID.

### RDS takes too long
RDS provisioning takes 5–10 minutes. This is normal — wait for status `available`.

### CodePipeline stuck at Source
The GitHub connection needs to be authorized in the AWS Console. See Step 9.

### Lambda invoke fails — resource not found
Wait for EC2 and RDS to be in running/available state before invoking the STOP Lambda.

---

## Commands Quick Reference

```bash
terraform init          # Initialize providers and backend
terraform validate      # Check syntax
terraform plan          # Preview changes
terraform apply         # Deploy
terraform output        # Show outputs
terraform destroy       # Tear down everything
```
