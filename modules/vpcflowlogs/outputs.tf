
output "flow_log_id" {
  description = "VPC Flow Log ID."
  value       = aws_flow_log.this.id
}

output "log_group_name" {
  description = "CloudWatch Logs group name."
  value       = aws_cloudwatch_log_group.this.name
}

output "iam_role_arn" {
  description = "IAM role used for log delivery."
  value       = aws_iam_role.this.arn
}
