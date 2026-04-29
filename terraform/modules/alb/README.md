# ALB Module

Internet-facing Application Load Balancer with HTTP listener and target group.

## Resources Created
- 1 Security Group (HTTP/80 from internet)
- 1 Application Load Balancer (`internet-facing`)
- 1 Target Group (port 80, HTTP, instance type)
- 1 HTTP Listener on port 80
- Health Check enabled (`HTTP /` on traffic-port, matcher 200)

## Inputs
| Name | Description |
|------|-------------|
| `name_prefix` | Resource name prefix |
| `vpc_id` | VPC ID |
| `public_subnet_ids` | Public subnet IDs (multi-AZ) |
| `tags` | Common tags |

## Outputs
- `alb_arn`, `alb_dns_name`, `alb_zone_id`, `alb_security_group_id`
- `target_group_arn`, `target_group_arn_suffix`, `alb_arn_suffix`
