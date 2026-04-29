# Submission Folder

This folder contains all screenshots and logs collected **during** deployment — committed task-by-task, not at the end.

## Screenshot Naming Convention

Every screenshot filename is: `<step-number>_<description>.png`

## Folder Map

```
submission/
├── screenshots/
│   ├── 01_iam_setup/
│   │   ├── 01_cross_account_role_created.png
│   │   └── 02_role_trust_policy.png
│   │
│   ├── 02_terraform_server/
│   │   ├── 01_terraform_version.png
│   │   └── 02_aws_sts_identity.png
│   │
│   ├── 03_backend/
│   │   ├── 01_s3_bucket_created.png
│   │   ├── 02_s3_versioning_enabled.png
│   │   ├── 03_dynamodb_table_created.png
│   │   └── 04_terraform_init_success.png
│   │
│   ├── 04_vpc/
│   │   ├── 01_vpc_created.png
│   │   ├── 02_public_subnets.png
│   │   ├── 03_private_subnets.png
│   │   ├── 04_internet_gateway.png
│   │   ├── 05_nat_gateway.png
│   │   └── 06_route_tables.png
│   │
│   ├── 05_ec2_alb_asg/
│   │   ├── 01_ec2_instance_running.png
│   │   ├── 02_alb_active.png
│   │   ├── 03_alb_url_working.png          ← CRITICAL
│   │   ├── 04_target_group_healthy.png
│   │   ├── 05_asg_details.png
│   │   ├── 06_launch_template.png
│   │   └── 07_scaling_alarms.png
│   │
│   ├── 06_rds/
│   │   ├── 01_rds_instance_available.png
│   │   ├── 02_rds_configuration.png
│   │   └── 03_rds_connectivity_proof.png   ← CRITICAL
│   │
│   ├── 07_cicd/
│   │   ├── 01_github_connection_active.png
│   │   ├── 02_codepipeline_success.png     ← CRITICAL
│   │   ├── 03_codebuild_success.png
│   │   └── 04_codedeploy_success.png
│   │
│   ├── 08_cloudwatch/
│   │   ├── 01_dashboard_full.png           ← CRITICAL
│   │   ├── 02_ec2_cpu_widget.png
│   │   ├── 03_alb_widgets.png
│   │   └── 04_rds_widgets.png
│   │
│   ├── 09_lambda/
│   │   ├── 01_stop_lambda_execution.png    ← CRITICAL
│   │   ├── 02_start_lambda_execution.png
│   │   ├── 03_eventbridge_rules.png
│   │   ├── 04_ec2_stopped_by_lambda.png
│   │   └── 05_rds_stopped_by_lambda.png
│   │
│   └── 10_destroy/
│       └── 01_terraform_destroy_complete.png ← CRITICAL
│
└── logs/
    ├── lambda_stop_response.json
    └── lambda_start_response.json
```

## Commit Workflow (commit after EACH task)

```bash
# Generic pattern for every task
git add submission/screenshots/<task_folder>/
git commit -m "TASK-XX: <description> (screenshots added)"
git push
```

## ⚠️ Critical Screenshots (MUST be present for full marks)

| File | Marks at risk |
|------|--------------|
| `05_ec2_alb_asg/03_alb_url_working.png` | ALB working proof |
| `06_rds/03_rds_connectivity_proof.png` | RDS connectivity |
| `07_cicd/02_codepipeline_success.png` | CI/CD proof |
| `08_cloudwatch/01_dashboard_full.png` | Monitoring proof |
| `09_lambda/01_stop_lambda_execution.png` | Lambda proof |
| `10_destroy/01_terraform_destroy_complete.png` | Destroy proof |
