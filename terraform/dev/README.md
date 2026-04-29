# Dev Environment

This is the active Terraform environment that deploys all infrastructure into **Ayush's AWS account** using cross-account IAM.

## Files
| File | Purpose |
|------|---------|
| `backend.tf` | Remote state: S3 bucket + DynamoDB lock |
| `provider.tf` | AWS provider with `assume_role` (cross-account) |
| `variables.tf` | All variable declarations |
| `terraform.tfvars` | Non-sensitive values (commit this) |
| `main.tf` | Calls all 8 modules |
| `outputs.tf` | Key outputs post-apply |

## cicd_assets/
| File | Purpose |
|------|---------|
| `buildspec.yml` | CodeBuild — copy to app repo root |
| `appspec.yml` | CodeDeploy — copy to app repo root |
| `scripts/` | CodeDeploy lifecycle hooks |

## Deployment Steps
See the [root README](../README.md) for the full step-by-step deployment guide.

## Quick commands
```bash
export TF_VAR_db_password='YourPassword!'
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```
