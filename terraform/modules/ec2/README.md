# EC2 Module

Provisions a single Amazon Linux 2 EC2 instance in a public subnet, with an attached IAM role (SSM + CodeDeploy + CloudWatch), security group, and a user-data script that installs nginx and serves the welcome page.

## Resources Created
- 1 Security Group (allows HTTP from ALB SG, SSH from admin CIDR)
- 1 IAM Role with managed policies: `AmazonSSMManagedInstanceCore`, `AmazonEC2RoleforAWSCodeDeploy`, `CloudWatchAgentServerPolicy`
- 1 IAM Instance Profile
- 1 EC2 Instance (`t2.micro`, 8 GB gp2, monitoring enabled, public IP)

## Inputs
| Name | Description |
|------|-------------|
| `name_prefix` | Resource name prefix |
| `vpc_id` | VPC ID |
| `public_subnet_id` | Public subnet ID for the instance |
| `alb_security_group_id` | ALB SG (allowed for port 80 ingress) |
| `ssh_allowed_cidrs` | CIDRs allowed for SSH |
| `instance_type` | Default `t2.micro` |
| `key_name` | Existing EC2 key pair name |
| `welcome_message` | Page text (default: "Terraform Practical Test Completed") |
| `tags` | Common tags |

## Outputs
- `instance_id`, `public_ip`, `security_group_id`, `iam_role_name`, `iam_instance_profile_name`

## Tags
The instance is tagged `AutoSchedule=true` so the Lambda scheduler picks it up.
