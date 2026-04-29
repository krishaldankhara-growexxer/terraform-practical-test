# ---------- Zip the Python function ----------
data "archive_file" "scheduler" {
  type        = "zip"
  source_file = "${path.module}/scheduler.py"
  output_path = "${path.module}/scheduler.zip"
}

# ---------- IAM Role for Lambda ----------
resource "aws_iam_role" "lambda" {
  name = "${var.name_prefix}-scheduler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "lambda" {
  name = "${var.name_prefix}-scheduler-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:StartInstances",
          "ec2:StopInstances"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBInstances",
          "rds:ListTagsForResource",
          "rds:StartDBInstance",
          "rds:StopDBInstance"
        ]
        Resource = "*"
      }
    ]
  })
}

# ---------- STOP Lambda (8 PM IST = 14:30 UTC) ----------
resource "aws_lambda_function" "stop" {
  function_name    = "${var.name_prefix}-scheduler-stop"
  role             = aws_iam_role.lambda.arn
  filename         = data.archive_file.scheduler.output_path
  source_code_hash = data.archive_file.scheduler.output_base64sha256
  handler          = "scheduler.lambda_handler"
  runtime          = "python3.12"
  timeout          = 60

  environment {
    variables = {
      ACTION    = "stop"
      TAG_KEY   = "AutoSchedule"
      TAG_VALUE = "true"
    }
  }

  tags = var.tags
}

# ---------- START Lambda (8 AM IST = 02:30 UTC) ----------
resource "aws_lambda_function" "start" {
  function_name    = "${var.name_prefix}-scheduler-start"
  role             = aws_iam_role.lambda.arn
  filename         = data.archive_file.scheduler.output_path
  source_code_hash = data.archive_file.scheduler.output_base64sha256
  handler          = "scheduler.lambda_handler"
  runtime          = "python3.12"
  timeout          = 60

  environment {
    variables = {
      ACTION    = "start"
      TAG_KEY   = "AutoSchedule"
      TAG_VALUE = "true"
    }
  }

  tags = var.tags
}

# ---------- CloudWatch Log Groups ----------
resource "aws_cloudwatch_log_group" "stop" {
  name              = "/aws/lambda/${aws_lambda_function.stop.function_name}"
  retention_in_days = 7
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "start" {
  name              = "/aws/lambda/${aws_lambda_function.start.function_name}"
  retention_in_days = 7
  tags              = var.tags
}

# ---------- EventBridge rule - STOP at 8 PM IST (14:30 UTC) ----------
resource "aws_cloudwatch_event_rule" "stop" {
  name                = "${var.name_prefix}-stop-rule"
  description         = "Stop EC2 and RDS at 8 PM IST"
  schedule_expression = "cron(30 14 * * ? *)"
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "stop" {
  rule      = aws_cloudwatch_event_rule.stop.name
  target_id = "StopScheduler"
  arn       = aws_lambda_function.stop.arn
}

resource "aws_lambda_permission" "stop" {
  statement_id  = "AllowEventBridgeStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop.arn
}

# ---------- EventBridge rule - START at 8 AM IST (02:30 UTC) ----------
resource "aws_cloudwatch_event_rule" "start" {
  name                = "${var.name_prefix}-start-rule"
  description         = "Start EC2 and RDS at 8 AM IST"
  schedule_expression = "cron(30 2 * * ? *)"
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "start" {
  rule      = aws_cloudwatch_event_rule.start.name
  target_id = "StartScheduler"
  arn       = aws_lambda_function.start.arn
}

resource "aws_lambda_permission" "start" {
  statement_id  = "AllowEventBridgeStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start.arn
}
