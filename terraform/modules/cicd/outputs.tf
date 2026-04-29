output "pipeline_name" {
  description = "Name of the CodePipeline"
  value       = aws_codepipeline.this.name
}

output "codebuild_project_name" {
  description = "Name of the CodeBuild project"
  value       = aws_codebuild_project.this.name
}

output "codedeploy_app_name" {
  description = "Name of the CodeDeploy application"
  value       = aws_codedeploy_app.this.name
}

output "codedeploy_deployment_group_name" {
  description = "Name of the CodeDeploy deployment group"
  value       = aws_codedeploy_deployment_group.this.deployment_group_name
}

output "artifact_bucket_name" {
  description = "Pipeline artifact bucket"
  value       = aws_s3_bucket.artifacts.bucket
}

output "github_connection_arn" {
  description = "ARN of the CodeStar GitHub connection (authorize this in the console)"
  value       = aws_codestarconnections_connection.github.arn
}
