# RDS Module

MySQL RDS instance, deployed only in private subnets, protected by a dedicated security group that only permits traffic from the application tier.

## Resources Created
- 1 DB Subnet Group (private subnets only)
- 1 Security Group (port 3306 from app SG only)
- 1 RDS MySQL Instance:
  - Engine: MySQL 8.0
  - Class: `db.t3.micro`
  - Storage: 20 GB gp2 (encrypted)
  - Multi-AZ: disabled
  - Public access: disabled
  - Backup retention: 7 days
  - Deletion protection: disabled
  - Tag: `AutoSchedule=true`

## Inputs
| Name | Description |
|------|-------------|
| `name_prefix` | Resource name prefix |
| `vpc_id` | VPC ID |
| `private_subnet_ids` | Private subnet IDs |
| `app_security_group_id` | Application SG (allowed for 3306 ingress) |
| `engine_version` | Default `8.0` |
| `instance_class` | Default `db.t3.micro` |
| `db_name`, `db_username`, `db_password` | DB credentials |
| `tags` | Common tags |

## Security
- `db_password` is `sensitive = true`. Pass it via:
  ```bash
  export TF_VAR_db_password='YourStrongPassword!'
  ```
  Never commit it to `terraform.tfvars`.

## Outputs
- `db_instance_id`, `db_endpoint`, `db_address`, `db_port`
- `db_security_group_id`, `db_subnet_group_name`
