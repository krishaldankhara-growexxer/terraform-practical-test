# Cost Estimation Summary

**Region:** ap-south-1 (Mumbai) | **Basis:** 720 hours (30 days, always-on)

> Prices reflect AWS ap-south-1 on-demand rates as of April 2026.
> Free Tier column applies only to new AWS accounts within the first 12 months.

---

## Resource Inventory (from Terraform code)

| Module | Resource | Type / Size |
| --- | --- | --- |
| vpc | VPC, 2 public + 2 private subnets | 10.0.0.0/16 |
| vpc | Internet Gateway | 1 |
| vpc | Elastic IP (for NAT) | 1 |
| vpc | NAT Gateway | 1 (ap-south-1a) |
| alb | Application Load Balancer | Internet-facing, port 80 |
| ec2 | Demo EC2 instance | t2.micro, 8 GB gp2 |
| asg | ASG Launch Template + 1 instance | t2.micro, 8 GB gp2, desired=1 max=2 |
| rds | RDS MySQL | db.t3.micro, 20 GB gp2, single-AZ |
| cicd | S3 artifacts bucket | < 1 GB |
| dev/main.tf | S3 state bucket | < 1 GB |
| dev/main.tf | DynamoDB state lock table | PAY_PER_REQUEST |
| lambda | 2 Lambda functions (stop/start) | Python 3.12, 128 MB |
| lambda | 2 CloudWatch Log Groups | 7-day retention |
| lambda | 2 EventBridge rules | Cron: 02:30 UTC + 14:30 UTC daily |
| cloudwatch | CloudWatch Dashboard | 1 dashboard, 7 widgets |
| asg | CloudWatch Alarms | 2 (CPU > 70%, CPU < 30%) |
| cicd | CodePipeline | 1 active pipeline |
| cicd | CodeBuild project | BUILD_GENERAL1_SMALL |
| cicd | CodeDeploy app + deployment group | EC2 in-place |
| cicd | CodeStar GitHub Connection | 1 |

> **Note:** Both `module.ec2` (standalone demo instance) and `module.asg` (ASG with desired=1) are deployed simultaneously — that is **2 x t2.micro** instances running at all times.

---

## Monthly Cost Breakdown

| # | Service | Configuration | Unit Price | Qty (720 hrs) | Monthly Cost | Free Tier |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | EC2 t2.micro | Demo instance | $0.0116/hr | 720 hrs | $8.35 | 750 hrs free |
| 2 | EC2 t2.micro | ASG instance (desired=1) | $0.0116/hr | 720 hrs | $8.35 | Shared with #1 — 690 hrs billed |
| 3 | EBS gp2 | 2 volumes × 8 GB = 16 GB | $0.114/GB-mo | 16 GB | $1.82 | 30 GB free |
| 4 | NAT Gateway | Fixed hourly | $0.045/hr | 720 hrs | $32.40 | None |
| 5 | NAT Gateway | Data processing | $0.045/GB | ~5 GB/mo | $0.23 | None |
| 6 | ALB | Fixed hourly | $0.016/hr | 720 hrs | $11.52 | None |
| 7 | ALB | LCU charges (minimal traffic) | $0.008/LCU-hr | ~0.1 LCU avg | $0.58 | None |
| 8 | RDS db.t3.micro | MySQL, single-AZ | $0.017/hr | 720 hrs | $12.24 | 750 hrs free |
| 9 | RDS storage | 20 GB gp2 | $0.115/GB-mo | 20 GB | $2.30 | 20 GB free |
| 10 | S3 state bucket | < 0.1 GB storage | $0.025/GB-mo | < 0.1 GB | < $0.01 | 5 GB free |
| 11 | S3 artifacts bucket | < 0.5 GB storage | $0.025/GB-mo | < 0.5 GB | < $0.02 | 5 GB free |
| 12 | DynamoDB lock table | PAY_PER_REQUEST, ~few reads/writes | $1.25/M writes | Negligible | < $0.01 | 25 GB free |
| 13 | Lambda | 2 functions × 2 calls/day = ~60/mo | $0.20/1M req | 60 calls | $0.00 | 1M req/mo free |
| 14 | CloudWatch Dashboard | 1 dashboard | $3.00/dashboard | 1 | $3.00 | 3 free (12-mo) |
| 15 | CloudWatch Alarms | 2 standard alarms (scale-in/out) | $0.10/alarm | 2 | $0.20 | 10 free (12-mo) |
| 16 | CloudWatch Logs | Lambda + CodeBuild logs | $0.57/GB ingested | < 0.1 GB | < $0.10 | 5 GB free |
| 17 | CodeBuild | BUILD_GENERAL1_SMALL | $0.005/min | ~30 min/mo | $0.00 | 100 min/mo free |
| 18 | CodePipeline | 1 active pipeline | $1.00/pipeline | 1 | $0.00 | 1 free permanently |
| 19 | CodeDeploy | EC2 in-place deployments | Free | — | $0.00 | Always free |
| 20 | EventBridge | 2 rules, ~60 events/mo | Free | < 5M/mo | $0.00 | 5M events free |
| 21 | Elastic IP | 1 EIP, in-use (no idle charge) | — | In use | $0.00 | — |
| 22 | Internet Gateway | Data transfer out (~1 GB) | $0.109/GB | ~1 GB | ~$0.11 | — |

---

## Scenario Totals

| Scenario | Monthly Cost | Notes |
| --- | --- | --- |
| **Without Free Tier (full cost)** | **~$81 / month** | All resources billed at on-demand rates |
| **With 12-Month Free Tier** | **~$48 / month** | EC2 (750 hrs free), EBS (30 GB free), RDS (750 hrs + 20 GB free), CW free |
| **Without Free Tier + Lambda Scheduler** | **~$50 / month** | NAT/EC2 run 12 hrs/day → ~50% off those costs |
| **With Free Tier + Lambda Scheduler** | **~$30 / month** | Best-case: new account + scheduler active |

---

## Cost Driver Analysis

```text
Without Free Tier (full cost ~$81/month):

  NAT Gateway      ████████████████████  $32.40  (40%)
  RDS MySQL        ██████████           $14.54  (18%)
  ALB              ████████             $12.10  (15%)
  EC2 (2 instances)█████████            $16.70  (21%)
  CloudWatch       ██                   $3.20   ( 4%)
  Other            █                    $0.50   ( 1%)
```

**NAT Gateway is the #1 cost driver** — $32.40/month regardless of traffic.
It is always-on and cannot be stopped. Destroy it when the environment is not in use.

---

## Lambda Scheduler Impact

The `tf-test-scheduler-stop` and `tf-test-scheduler-start` Lambda functions run on EventBridge cron:

| Event | Time (IST) | Time (UTC) |
| --- | --- | --- |
| Stop EC2 + RDS | 8:00 PM | 14:30 UTC |
| Start EC2 + RDS | 8:00 AM | 02:30 UTC |

**Active hours per day:** 12 hrs out of 24

| Resource | Scheduler Benefit |
| --- | --- |
| EC2 instances (×2) | ~50% saving → saves ~$8.35/month |
| RDS MySQL | ~50% saving on instance hrs → saves ~$6.12/month (storage still billed) |
| NAT Gateway | ~50% saving (no EC2 traffic when stopped) → saves ~$16.20/month |
| ALB | No saving — hourly charge is fixed even with 0 targets |

Total monthly savings with scheduler: **~$30.67**

---

## Key Notes

- **Two EC2 instances run simultaneously**: the standalone demo EC2 (`module.ec2`) and one ASG instance (`module.asg`, desired=1). Free Tier covers only 750 combined hours.
- **NAT Gateway cannot be stopped** — it bills 24/7 regardless of whether EC2/RDS are running. It is the primary cost even with the Lambda scheduler.
- **RDS when stopped** continues to bill for storage ($2.30/month) and auto-restarts after 7 days if not manually started.
- **ALB** bills fixed hourly even with no healthy targets. It does not save cost when EC2 is stopped.
- **CodeBuild** has a permanent 100 build-minutes/month free tier (not 12-month). Typical builds are 2–4 min each.
- **CodePipeline** first pipeline per account is permanently free.
- **Destroy all resources** after testing to avoid ongoing NAT Gateway + ALB charges.
