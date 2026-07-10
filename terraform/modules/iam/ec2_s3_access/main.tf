# EC2 server IAM permissions

resource "aws_iam_role" "ec2_role" {
    path = "/"
    name = "rock-ec2-sql-role"
    assume_role_policy = jsonencode ({
        Version = "2012-10-17",
        Statement = [{
            Effect = "Allow",
            Principal = {
                Service = [
                    "ec2.amazonaws.com",
                    "ssm.amazonaws.com"
                ]
            },
            Action = "sts:AssumeRole"
        }]
    })
    max_session_duration = 43200
    tags = {}
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "rock-ec2-sql-role"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "rock-ec2-sql-s3-policy"
  path        = "/"
  description = "EC2 S3 Policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
             "Action": [
                 "s3:ListBucket",
                 "s3:GetBucketLocation"
            ],
             "Resource": "${var.s3_bucket_arn}",
             "Effect": "Allow"
        },
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_managed_policy_attach" {
  role          = aws_iam_role.ec2_role.name
  policy_arn    = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_policy_attach" {
  role          = aws_iam_role.ec2_role.name
  policy_arn    = aws_iam_policy.ec2_policy.arn
}