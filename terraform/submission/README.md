# Submission Folder

This folder contains all screenshots and logs collected **during** deployment — committed task-by-task, not at the end.

## Screenshot Naming Convention

Every screenshot filename is: `<step-number>_<description>.png`

## Folder Map

```
submission/
└── screenshots/
    ├── 01_iam_setup/
    │   ├── 01_cross_account_role_created.png
    │   └── 02_role_trust_policy.png
    │
    ├── 02_terraform_server/
    │   ├── 01_terraform_server.png
    │   ├── 02_terraform_installation.png
    │   └── 03_git_unzip_installation.png
    │
    ├── 03_backend/
    │   ├── 01_s3_bucket_created.png
    │   ├── 02_s3_versioning_enabled.png
    │   ├── 03_s3_encryption_enabled.png
    │   ├── 04_s3_block_public_access.png
    │   └── 05_terraform_migrate_success.png
    │
    ├── 04_vpc/
    │   ├── 01_vpc_created.png
    │   ├── 02_public_subnet_1a.png
    │   ├── 03_public_subnet_1b.png
    │   ├── 04_private_subnet_1a.png
    │   ├── 05_private_subnet_1b.png
    │   ├── 06_internet_gateway.png
    │   ├── 07_nat_gateway.png
    │   ├── 08_public_rt.png
    │   └── 09_private_rt.png
    │
    ├── 05_ec2_alb_asg/
    │   ├── 01_ec2_running.png
    │   ├── 02_ec2_volume.png
    │   ├── 03_ec2_monitoring_enabled.png
    │   ├── 04_alb_active.png
    │   ├── 05_ALB_url_working.png              ← CRITICAL
    │   ├── 06_target_group_healthy.png
    │   ├── 07_asg_details.png
    │   ├── 08_launch_template.png
    │   ├── 09.01_cpu_<30%_alarm.png
    │   ├── 09.02_cpu_low_alarm_action.png
    │   ├── 10.01_cpu_>70%_alarm.png
    │   └── 10.02_cpu_high_alarm_action.png
    │
    ├── 06_rds/
    │   └── 01_rds_configuration.png
    │
    ├── 07_cicd/
    │   ├── 01_github_connection_active.png
    │   ├── 02_codepipeline_success.png         ← CRITICAL
    │   ├── 03_codebuild_suceeded.png
    │   └── 04_code_deploy_success.png
    │
    ├── 08_cloudwatch/
    │   └── 01_cloudwatch_dashboard.png         ← CRITICAL
    │
    ├── 09_lambda/
    │   ├── 01_lambda.png
    │   ├── 02_stop_lambda_execution.png        ← CRITICAL
    │   ├── 03_start_lambda_execution.png
    │   └── 04_eventbridge_rules.png
    │
    └── 10_destroy/
        (pending)
```