# CloudWatch Module

Creates a single CloudWatch Dashboard with widgets covering EC2, ALB, and RDS metrics as required by the assignment.

## Dashboard Widgets

| Widget | Metrics |
|--------|---------|
| EC2 CPU Utilization | `CPUUtilization` (by ASG name) |
| EC2 Disk + Network | `DiskReadBytes`, `DiskWriteBytes`, `NetworkIn`, `NetworkOut` |
| ALB Request Count | `RequestCount` |
| ALB Healthy/Unhealthy Hosts | `HealthyHostCount`, `UnHealthyHostCount` |
| RDS CPU | `CPUUtilization` |
| RDS Free Storage | `FreeStorageSpace` |
| RDS Connections | `DatabaseConnections` |

## Inputs
| Name | Description |
|------|-------------|
| `name_prefix` | Dashboard name prefix |
| `region` | AWS region |
| `asg_name` | ASG name (for EC2 metrics dimension) |
| `alb_arn_suffix` | ALB ARN suffix (from alb module) |
| `target_group_arn_suffix` | Target group ARN suffix (from alb module) |
| `db_instance_id` | RDS instance identifier |
| `tags` | Common tags |

## Outputs
- `dashboard_name`, `dashboard_arn`

## Usage
```hcl
module "cloudwatch" {
  source                  = "../modules/cloudwatch"
  name_prefix             = var.name_prefix
  region                  = var.region
  asg_name                = module.asg.asg_name
  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix
  db_instance_id          = module.rds.db_instance_id
  tags                    = local.common_tags
}
```
