# 🏗️ Terraform Practical Test

### Cross-Account AWS Infrastructure — Fully Automated, Production-Grade

[![Terraform](https://img.shields.io/badge/Terraform-1.6+-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/Amazon_AWS-Cross_Account-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)](https://aws.amazon.com/)
[![Python](https://img.shields.io/badge/Python-Lambda-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-CodePipeline-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white)](https://aws.amazon.com/codepipeline/)

> **One `terraform apply` to rule them all** —
> deploy a fully automated, cross-account AWS stack with CI/CD, auto-scaling, monitoring, and a Lambda cost scheduler.

---

## 🗺️ Infrastructure at a Glance

```
┌─────────────────────────────────────────────────────────────────────┐
│                      Krishal Account                                │
│                                                                     │
│   🖥️  Terraform Server (EC2)  ──── assumes IAM role ──────────────► │
└──────────────────────────────────────────────────────────┬──────────┘
                                                           │
                                                           ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      Target AWS Account (Ayush)                     │
│                                                                     │
│   🌐  Public Subnets (1a + 1b)                                      │
│        └── 🔀 Application Load Balancer  (port 80)                  │
│                         │                                           │
│   🔒  Private Subnets (1a + 1b)                                     │
│        ├── ⚡  EC2 t2.micro  ←  Auto Scaling Group                  │
│        └── 🗄️  RDS MySQL  db.t3.micro                               │
│                                                                     │
│   🚀  GitHub → CodePipeline → CodeBuild → CodeDeploy                │
│   📊  CloudWatch Dashboard + Alarms                                 │
│   ⏰  Lambda Scheduler  (8 PM stop  /  8 AM start)                  │
└─────────────────────────────────────────────────────────────────────┘
```

---

## ✨ What Makes This Special

### 🔐 Cross-Account Deploy

Terraform runs in Account A and provisions all resources in Account B using a scoped IAM role — no shared credentials, no credential sprawl.

### 🧩 8 Independent Terraform Modules

`vpc` · `ec2` · `alb` · `asg` · `rds` · `cicd` · `cloudwatch` · `lambda` — each isolated, reusable, and independently testable.

### 💸 Auto Cost Control

A Python Lambda + EventBridge **stops** EC2 and RDS every night and **restarts** them every morning — zero manual babysitting.

### 🚀 Push-to-Deploy CI/CD

Every `git push` to `main` triggers CodePipeline → CodeBuild → CodeDeploy onto the live EC2 instance automatically.

### 📈 Auto Scaling

CPU-based scale-out and scale-in policies via ASG — handles traffic spikes without manual intervention.

### 🔒 Remote State

S3 backend + DynamoDB locking ensures no state corruption across concurrent runs or team members.

---

## 📦 Tech Stack

![VPC](https://img.shields.io/badge/AWS-VPC-FF9900?style=flat-square&logo=amazonaws)
![EC2](https://img.shields.io/badge/AWS-EC2_t2.micro-FF9900?style=flat-square&logo=amazonec2)
![ALB](https://img.shields.io/badge/AWS-Load_Balancer-FF9900?style=flat-square&logo=amazonaws)
![ASG](https://img.shields.io/badge/AWS-Auto_Scaling-FF9900?style=flat-square&logo=amazonaws)
![RDS](https://img.shields.io/badge/AWS-RDS_MySQL-527FFF?style=flat-square&logo=amazonrds)
![CodePipeline](https://img.shields.io/badge/AWS-CodePipeline-232F3E?style=flat-square&logo=amazonaws)
![Lambda](https://img.shields.io/badge/AWS-Lambda-FF9900?style=flat-square&logo=awslambda)
![EventBridge](https://img.shields.io/badge/AWS-EventBridge-E7157B?style=flat-square&logo=amazonaws)
![CloudWatch](https://img.shields.io/badge/AWS-CloudWatch-FF4F8B?style=flat-square&logo=amazonaws)
![S3](https://img.shields.io/badge/AWS-S3_State-569A31?style=flat-square&logo=amazons3)
![DynamoDB](https://img.shields.io/badge/AWS-DynamoDB_Lock-4053D6?style=flat-square&logo=amazondynamodb)
![Nginx](https://img.shields.io/badge/Server-Nginx-009639?style=flat-square&logo=nginx)

---

## 🚀 Deploy in 4 Commands

```bash
# 1 — move into the working environment
cd terraform/dev

# 2 — set the DB password safely (never in tfvars)
export TF_VAR_db_password='YourStrongPassword123!'

# 3 — initialize providers and remote backend
terraform init

# 4 — ship it
terraform apply -auto-approve
```

> 📖 Full prerequisites, cross-account setup, and step-by-step walkthrough → **[terraform/README.md](terraform/README.md)**

---

## 📸 Proof of Deployment

| # | Screenshot | Status |
| --- | --- | :---: |
| 1 | ALB serving Nginx over the load balancer | ✅ |
| 2 | CodePipeline end-to-end success | ✅ |
| 3 | CodeBuild + CodeDeploy configured | ✅ |
| 4 | CloudWatch live metrics dashboard | ✅ |
| 5 | Lambda stop scheduler invoked | ✅ |
| 6 | Lambda start scheduler invoked | ✅ |

All screenshots → [`terraform/submission/screenshots/`](terraform/submission/screenshots/)
Full task breakdown → [`terraform/submission/README.md`](terraform/submission/README.md)

---

## 💰 Estimated Monthly Cost

| Service | Cost |
| --- | :---: |
| EC2 t2.micro | `Free Tier` |
| RDS db.t3.micro | `Free Tier` |
| Lambda + EventBridge | `Free Tier` |
| CloudWatch | `Free Tier` |
| NAT Gateway | `~$32` |
| ALB | `~$12` |
| S3 + DynamoDB | `< $1` |
| **Total** | **~$45 / month** |

> ⚡ Lambda scheduler cuts ~16 hrs/day of NAT + RDS cost during nights and weekends.

---

## 👤 Author

**Krishal** · [![GitHub](https://img.shields.io/badge/GitHub-krishaldankhara--growexxer-181717?style=flat-square&logo=github)](https://github.com/krishaldankhara-growexxer)

*Internship infrastructure practical — production-style cross-account AWS deployment with Terraform.*
