# Cost Estimation Summary

**Region:** ap-south-1 (Mumbai) | **Duration:** 30 days

| Service | Configuration | Estimated Cost |
|---------|--------------|---------------|
| EC2 (t2.micro) | 1 instance, Free Tier (750 hrs/month) | $0.00 |
| EC2 ASG instances (t2.micro) | 1 desired, Free Tier | $0.00 |
| RDS MySQL (db.t3.micro) | 20 GB gp2, Free Tier (750 hrs/month) | $0.00 |
| NAT Gateway | 1 gateway (~$0.045/hr) + data transfer | ~$33.00 |
| Application Load Balancer | ~$0.016/hr + LCU charges | ~$12.00 |
| S3 (state bucket) | < 1 GB storage + minimal requests | < $1.00 |
| S3 (pipeline artifacts) | < 1 GB storage | < $1.00 |
| DynamoDB (state lock) | PAY_PER_REQUEST, minimal usage | < $1.00 |
| Lambda | Free Tier (1M invocations/month, 400K GB-sec) | $0.00 |
| CloudWatch (Dashboard) | 1 dashboard = $3.00/month | $3.00 |
| CloudWatch (Logs) | Lambda + CodeBuild logs, < 5 GB | < $1.00 |
| CodeBuild | 100 build-minutes Free Tier | $0.00 |
| CodePipeline | 1 active pipeline, 1 free/month | $0.00 |
| Elastic IP (NAT) | 1 EIP in use = no charge | $0.00 |
| **TOTAL (monthly)** | | **~$50.00** |

## Notes
- EC2 and RDS are within Free Tier limits (12 months new accounts).
- NAT Gateway is the primary cost driver (~65% of total).
- Lambda scheduler (start at 8AM / stop at 8PM IST) reduces costs by ~50% on non-Free-Tier resources since NAT Gateway charges are time-based.
- With Lambda scheduler active: effective NAT Gateway cost ≈ **~$16.50** (12 hrs/day active).
- Adjusted total with scheduler savings: **~$33/month**.
