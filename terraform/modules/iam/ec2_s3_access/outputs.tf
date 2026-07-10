output "s3_access_role" {
    value = aws_iam_role.ec2_role.arn
}

output "ec2_profile" {
    value = aws_iam_instance_profile.ec2_profile.arn
}
