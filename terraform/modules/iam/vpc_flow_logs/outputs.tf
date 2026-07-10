output "vpc_flow_logs_role" {
    value = aws_iam_role.vpc_flow_logs_role.arn
}