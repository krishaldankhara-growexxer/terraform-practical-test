# CICD Module

CodePipeline (Source → Build → Deploy) wired to GitHub via a CodeStar Connection, building with CodeBuild and deploying to EC2 via CodeDeploy.

## Resources Created
- 1 S3 bucket (pipeline artifacts; versioned, encrypted, public access blocked)
- 1 CodeStar Connection (GitHub) — **must be authorized manually after `terraform apply`**
- 1 CodeBuild project (uses `buildspec.yml` from the repo)
- 1 CodeDeploy application + deployment group (filters EC2 by tag `AutoSchedule=true`)
- 1 CodePipeline (Source → Build → Deploy)
- IAM roles for CodeBuild, CodeDeploy, CodePipeline

## ⚠️ Manual step required after `terraform apply`
The CodeStar GitHub connection is created in `PENDING` status. You **must** authorize it once in the AWS Console:

1. Go to **Developer Tools → Settings → Connections**.
2. Find `<name_prefix>-github-conn` → click **Update pending connection**.
3. Authorize it against your GitHub account/org.
4. Re-run the pipeline (Release change).

This is the only manual step in the CI/CD flow and is unavoidable due to OAuth.

## Inputs
| Name | Description |
|------|-------------|
| `name_prefix` | Resource name prefix |
| `account_id` | Target AWS account ID |
| `github_owner` | GitHub owner/org |
| `github_repo` | GitHub repository name |
| `github_branch` | Default `main` |
| `tags` | Common tags |

## Outputs
- `pipeline_name`, `codebuild_project_name`, `codedeploy_app_name`, `codedeploy_deployment_group_name`
- `artifact_bucket_name`, `github_connection_arn`

## Required files in your application repo
- `buildspec.yml` (used by CodeBuild)
- `appspec.yml` + `scripts/` (used by CodeDeploy)

Sample copies are provided in `dev/cicd_assets/` for reference.
