# Lambda Module

Two Lambda functions (start + stop) triggered by EventBridge cron rules. Filters resources by tag `AutoSchedule=true`.

## Schedule (IST)
| Action | IST | UTC cron |
|--------|-----|----------|
| START resources | 8:00 AM IST | `cron(30 2 * * ? *)` |
| STOP resources | 8:00 PM IST | `cron(30 14 * * ? *)` |

## Resources Created
- 1 IAM Role + inline policy (EC2/RDS start/stop + CloudWatch Logs)
- 2 Lambda functions (`scheduler-start`, `scheduler-stop`) — Python 3.12
- 2 CloudWatch Log Groups (7-day retention)
- 2 EventBridge rules (cron schedules)
- 2 EventBridge targets
- 2 Lambda permissions (allow EventBridge to invoke)

## Tag Filter
Resources must have tag `AutoSchedule=true` to be managed. Both EC2 instances and RDS instances are supported. Resources not carrying this tag are ignored.

## Inputs
| Name | Description |
|------|-------------|
| `name_prefix` | Resource name prefix |
| `tags` | Common tags |

## Outputs
- `stop_function_name`, `start_function_name`
- `stop_function_arn`, `start_function_arn`
- `stop_event_rule_name`, `start_event_rule_name`

## Testing manually (without waiting for schedule)
```bash
# Test STOP
aws lambda invoke \
  --function-name <name_prefix>-scheduler-stop \
  --region ap-south-1 \
  /tmp/stop_response.json
cat /tmp/stop_response.json

# Test START
aws lambda invoke \
  --function-name <name_prefix>-scheduler-start \
  --region ap-south-1 \
  /tmp/start_response.json
cat /tmp/start_response.json
```
