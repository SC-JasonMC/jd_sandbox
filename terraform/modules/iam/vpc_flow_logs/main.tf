# VPC Flow Logs IAM permissions

resource "aws_iam_role" "vpc_flow_logs_role" {
    path = "/"
    name = "${var.project_resource_name_prefix}-vpcflowlogs-role"
    assume_role_policy = jsonencode ({
        Version = "2012-10-17",
        Statement = [{
            Effect = "Allow",
            Principal = {
                Service = [
                    "vpc-flow-logs.amazonaws.com"
                ]
            },
            Action = "sts:AssumeRole"
        }]
    })
    tags = merge(
        var.tags,
        {

        }
    )
}

resource "aws_iam_policy" "vpc_flow_logs_policy" {
    name = "${var.project_resource_name_prefix}-vpcflowlogs-policy"
    path = "/"
    policy = jsonencode ({
        Version = "2012-10-17",
        Statement = [
            {
                    "Effect": "Allow",
                    "Action": [
                        "logs:CreateLogGroup",
                        "logs:CreateLogStream",
                        "logs:PutLogEvents",
                        "logs:DescribeLogGroups",
                        "logs:DescribeLogStreams"
                    ],
                    "Resource": "*"
                },
                {
                    "Effect": "Allow",
                    "Action": [
                        "iam:passrole"
                    ],
                    "Resource": "${aws_iam_role.vpc_flow_logs_role.arn}"
                }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "vpc_flow_logs_policy_attach" {
    role = aws_iam_role.vpc_flow_logs_role.name
    policy_arn = aws_iam_policy.vpc_flow_logs_policy.arn
}
