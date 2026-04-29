# ASG Module

Auto Scaling Group with Launch Template and CPU-based scaling policies, registered against the ALB target group.

## Resources Created
- 1 Launch Template (Amazon Linux 2, t2.micro, 8 GB gp2, monitoring enabled, user-data installs nginx + CodeDeploy agent)
- 1 Auto Scaling Group: min=1, desired=1, max=2
- 2 Scaling Policies (scale-out, scale-in) — `ChangeInCapacity ±1`
- 2 CloudWatch Alarms (CPU > 70% triggers scale-out, CPU < 30% triggers scale-in)
- ASG instances tagged `AutoSchedule=true`

## Inputs
| Name | Description |
|------|-------------|
| `name_prefix` | Resource name prefix |
| `instance_type` | Default `t2.micro` |
| `key_name` | EC2 key pair |
| `ec2_security_group_id` | SG for instances |
| `iam_instance_profile_name` | IAM profile (from EC2 module) |
| `public_subnet_ids` | Subnets for ASG instances |
| `target_group_arn` | ALB target group ARN |
| `min_size`, `desired_capacity`, `max_size` | Capacity settings (1/1/2) |
| `welcome_message` | Web page text |
| `tags` | Common tags |

## Outputs
- `asg_name`, `asg_arn`, `launch_template_id`, `scale_out_policy_arn`, `scale_in_policy_arn`
