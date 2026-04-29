output "stop_function_name" {
  description = "Name of the STOP Lambda function"
  value       = aws_lambda_function.stop.function_name
}

output "start_function_name" {
  description = "Name of the START Lambda function"
  value       = aws_lambda_function.start.function_name
}

output "stop_function_arn" {
  description = "ARN of the STOP Lambda function"
  value       = aws_lambda_function.stop.arn
}

output "start_function_arn" {
  description = "ARN of the START Lambda function"
  value       = aws_lambda_function.start.arn
}

output "stop_event_rule_name" {
  description = "EventBridge rule name for stop"
  value       = aws_cloudwatch_event_rule.stop.name
}

output "start_event_rule_name" {
  description = "EventBridge rule name for start"
  value       = aws_cloudwatch_event_rule.start.name
}
