# VPC Module

Creates a production-ready VPC with public/private subnets across two AZs, an Internet Gateway, a single NAT Gateway, and route tables.

## Resources Created
- 1 VPC (`10.0.0.0/16`)
- 2 Public Subnets (`10.0.1.0/24`, `10.0.2.0/24`)
- 2 Private Subnets (`10.0.3.0/24`, `10.0.4.0/24`)
- 1 Internet Gateway
- 1 NAT Gateway (with Elastic IP)
- 1 Public Route Table (route to IGW)
- 1 Private Route Table (route to NAT)
- Route Table Associations for all subnets

## Inputs
| Name | Type | Description |
|------|------|-------------|
| `vpc_cidr` | string | CIDR block for the VPC |
| `vpc_name` | string | Name tag for the VPC |
| `name_prefix` | string | Prefix for resource names |
| `azs` | list(string) | Availability zones |
| `public_subnet_cidrs` | list(string) | Public subnet CIDRs |
| `private_subnet_cidrs` | list(string) | Private subnet CIDRs |
| `tags` | map(string) | Common tags |

## Outputs
| Name | Description |
|------|-------------|
| `vpc_id` | The VPC ID |
| `vpc_cidr` | VPC CIDR block |
| `public_subnet_ids` | List of public subnet IDs |
| `private_subnet_ids` | List of private subnet IDs |
| `internet_gateway_id` | IGW ID |
| `nat_gateway_id` | NAT GW ID |

## Usage
```hcl
module "vpc" {
  source = "../modules/vpc"

  vpc_cidr             = "10.0.0.0/16"
  vpc_name             = "terraform-main-vpc"
  name_prefix          = "tf-test"
  azs                  = ["ap-south-1a", "ap-south-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  tags                 = { owner = "krishal" }
}
```
