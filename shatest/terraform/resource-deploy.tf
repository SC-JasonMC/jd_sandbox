

module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"
  
    name = "${var.project_name}-vpc"
    cidr = var.vpc_cidr_block
  
    # azs             = data.aws_availability_zones.available.names
    # intra_subnets = [for i in range(var.intra_subnets_count) : cidrsubnet(var.vpc_cidr_block, ((var.intra_subnets_length)-(local.vpc_cidr_block_parsed.length)), i)]
    private_subnets = [for i in range(var.private_subnets_count) : cidrsubnet(var.vpc_cidr_block, ((var.private_subnets_length)-(local.vpc_cidr_block_parsed.length)), i)]
    public_subnets  = [for i in range(var.public_subnets_count) : cidrsubnet(var.vpc_cidr_block, ((var.public_subnets_length)-(local.vpc_cidr_block_parsed.length)), i + var.private_subnets_count)]
    
    enable_nat_gateway = true
    single_nat_gateway = true
    one_nat_gateway_per_az = false
  
    manage_default_security_group = false
}
  
resource "aws_vpc_endpoint" "s3" {
    vpc_id       = module.vpc.vpc_id
    service_name = "com.amazonaws.${local.region}.s3"
    tags = {
        Environment = "SHA-test"
    }
}

resource "aws_vpc_endpoint" "ssm" {
    vpc_id       = module.vpc.vpc_id
    service_name = "com.amazonaws.${local.region}.ssm"
    vpc_endpoint_type = "Interface"
    security_group_ids = [
        aws_security_group.EndpointSecurityGroup.id,
    ]
    tags = {
        Environment = "SHA-test"
    }
}

resource "aws_vpc_endpoint" "ssmmessages" {
    vpc_id       = module.vpc.vpc_id
    service_name = "com.amazonaws.${local.region}.ssmmessages"
    vpc_endpoint_type = "Interface"
    security_group_ids = [
        aws_security_group.EndpointSecurityGroup.id,
    ]
    tags = {
        Environment = "SHA-test"
    }
}

resource "aws_vpc_endpoint" "ec2messages" {
    vpc_id       = module.vpc.vpc_id
    service_name = "com.amazonaws.${local.region}.ec2messages"
    vpc_endpoint_type = "Interface"
    security_group_ids = [
        aws_security_group.EndpointSecurityGroup.id,
    ]
    tags = {
        Environment = "SHA-test"
    }
}
  
resource "aws_iam_role" "SHAEC2Role" {
    path = "/"
    name = "SHAEC2Role"
    assume_role_policy = jsonencode ({
        Version = "2012-10-17",
        Statement = [{
            Effect = "Allow",
            Principal = {
                Service = "ec2.amazonaws.com"
            },
            Action = "sts:AssumeRole"
        }]
    })
    max_session_duration = 43200
    tags = {}
}

resource "aws_iam_instance_profile" "SHAEC2Profile" {
  name = "SHAEC2Profile"
  role = aws_iam_role.SHAEC2Role.name
}

resource "aws_iam_policy" "SHAEC2RoleAdditionalViewPolicy" {
    name = "SHAEC2RolePolicy"
    path = "/"
    policy = jsonencode ({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Action = "sts:AssumeRole"
                Resource = "arn:aws:iam::*:role/SHAExecRole"
            },
            {
                Effect = "Allow",
                Action = [
                    "account:Get*",
                    "appstream:Describe*",
                    "appstream:List*",
                    "backup:List*",
                    "cloudtrail:GetInsightSelectors",
                    "codeartifact:List*",
                    "codebuild:BatchGet*",
                    "drs:Describe*",
                    "ds:Get*",
                    "ds:Describe*",
                    "ds:List*",
                    "ec2:GetEbsEncryptionByDefault",
                    "ecr:Describe*",
                    "ecr:GetRegistryScanningConfiguration",
                    "elasticfilesystem:DescribeBackupPolicy",
                    "glue:GetConnections",
                    "glue:GetSecurityConfiguration*",
                    "glue:SearchTables",
                    "lambda:GetFunction*",
                    "logs:FilterLogEvents",
                    "macie2:GetMacieSession",
                    "s3:GetAccountPublicAccessBlock",
                    "shield:DescribeProtection",
                    "shield:GetSubscriptionState",
                    "securityhub:BatchImportFindings",
                    "securityhub:GetFindings",
                    "ssm:GetDocument",
                    "ssm-incidents:List*",
                    "support:Describe*",
                    "tag:GetTagKeys",
                    "wellarchitected:List*",
                    "organizations:DescribeOrganization",
                    "organizations:ListPolicies*",
                    "organizations:DescribePolicy",
                    "organizations:ListDelegatedAdministrators"
                ],
                Resource = "*"
            },
            {
                Effect = "Allow",
                Action = [
                    "apigateway:GET"
                ],
                Resource = [
                    "arn:aws:apigateway:*::/restapis/*",
                    "arn:aws:apigateway:*::/apis/*"
                ]
            },
            {
                Effect = "Allow",
                Action = [
                    "s3:PutObject*"
                ],
                Resource = [
                    "${aws_s3_bucket.sha_output_bucket.arn}/*"
                ]
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "EC2RoleCustomPolicyAttach" {
  role          = aws_iam_role.SHAEC2Role.name
  policy_arn    = aws_iam_policy.SHAEC2RoleAdditionalViewPolicy.arn
}

resource "aws_iam_role_policy_attachment" "EC2ManagedPoliciesAttachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", 
    "arn:aws:iam::aws:policy/SecurityAudit",
    "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
  ])

  role       = aws_iam_role.SHAEC2Role.name
  policy_arn = each.value
}

resource "aws_iam_role" "SHAExecRole" {
    path = "/"
    name = "SHAExecRole"
    assume_role_policy = jsonencode ({
        Version = "2012-10-17",
        Statement = [{
            Effect = "Allow",
            Principal = {
                AWS = "${aws_iam_role.SHAEC2Role.arn}"
            },
            Action = "sts:AssumeRole"
        }]
    })
    max_session_duration = 43200
    tags = {}
}

resource "aws_iam_policy" "SHAExecRoleAdditionalViewPrivileges" {
    name = "SHAExecRoleAdditionalViewPrivileges"
    path = "/"
    policy = jsonencode ({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Action = [
                    "account:Get*",
                    "appstream:Describe*",
                    "appstream:List*",
                    "backup:List*",
                    "cloudtrail:GetInsightSelectors",
                    "codeartifact:List*",
                    "codebuild:BatchGet*",
                    "dlm:Get*",
                    "drs:Describe*",
                    "ds:Get*",
                    "ds:Describe*",
                    "ds:List*",
                    "ec2:GetEbsEncryptionByDefault",
                    "ecr:Describe*",
                    "ecr:GetRegistryScanningConfiguration",
                    "elasticfilesystem:DescribeBackupPolicy",
                    "glue:GetConnections",
                    "glue:GetSecurityConfiguration*",
                    "glue:SearchTables",
                    "lambda:GetFunction*",
                    "logs:FilterLogEvents",
                    "macie2:GetMacieSession",
                    "s3:GetAccountPublicAccessBlock",
                    "shield:DescribeProtection",
                    "shield:GetSubscriptionState",
                    "securityhub:BatchImportFindings",
                    "securityhub:GetFindings",
                    "ssm:GetDocument",
                    "ssm-incidents:List*",
                    "support:Describe*",
                    "tag:GetTagKeys",
                    "wellarchitected:List*",
                    "organizations:DescribeOrganization",
                    "organizations:ListPolicies*",
                    "organizations:DescribePolicy",
                    "organizations:ListDelegatedAdministrators"
                ],
                Resource = "*"
            },
            {
                Effect = "Allow",
                Action = [
                    "apigateway:GET"
                ],
                Resource = [
                    "arn:aws:apigateway:*::/restapis/*",
                    "arn:aws:apigateway:*::/apis/*"
                ]
            },
        ]
    })
}

resource "aws_iam_role_policy_attachment" "ExecRoleCustomPolicyAttach" {
  role          = aws_iam_role.SHAExecRole.name
  policy_arn    = aws_iam_policy.SHAExecRoleAdditionalViewPrivileges.arn
}

resource "aws_iam_role_policy_attachment" "ExecRoleManagedPoliciesAttachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/SecurityAudit",
    "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
  ])

  role       = aws_iam_role.SHAExecRole.name
  policy_arn = each.value
}

resource "aws_s3_bucket" "sha_output_bucket" {
  bucket = "sha-output-${local.account_id}-${local.region}"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

# module "s3_bucket" {
#     source = "terraform-aws-modules/s3-bucket/aws"

#     bucket = "sha-output-${local.account_id}-${local.region}"
#     acl    = "private"

#     control_object_ownership = true
#     object_ownership         = "ObjectWriter"

#     versioning = {
#         enabled = false
#     }

#     policy = jsonencode ({
#         Version = "2012-10-17",
#         Statement = [
#             {
#                 Sid = "AllowPutObjectsFromEC2"
#                 Effect = "Allow",
#                 Principal = {
#                     AWS = "${resource.aws_iam_role.SHAEC2Role}"
#                 },
#                 Action = "s3:PutObject*",
#                 Resource = "${module.s3_bucket.s3_bucket_arn}/*"
#             },
#             {
#                 Sid = "DenyNonHTTPSAccess"
#                 Effect = "Deny",
#                 Principal = "*",
#                 Action = "s3:*",
#                 Resource = [
#                     "${module.s3_bucket.s3_bucket_arn}",
#                     "${module.s3_bucket.s3_bucket_arn}/*"
#                 ],
#                 Condition = {
#                     Bool = {
#                         "aws:SecureTransport" = "false"
#                     }
#                 }
#             }
#         ]
#     })

# }

resource "aws_instance" "EC2Instance" {
    ami = "ami-0fa3fe0fa7920f68e"
    instance_type = var.instance_type
    availability_zone = "us-east-1a"
    tenancy = "default"
    subnet_id = module.vpc.private_subnets[0]
    ebs_optimized = false
    vpc_security_group_ids = [
        "${aws_security_group.EC2SecurityGroup.id}"
    ]
    source_dest_check = true
    root_block_device {
        volume_size = 24
        volume_type = "gp3"
        delete_on_termination = true
    }
    user_data = base64encode(templatefile("${path.module}/userdata.sh", {
        s3_bucket       = "${aws_s3_bucket.sha_output_bucket.arn}"
        parallelism     = "${var.parallelism}"
        iam_role        = "${aws_iam_role.SHAExecRole.name}"
        finding_output  = "${var.finding_output}"
        account_scope   = "${var.account_list}"
    }))
    iam_instance_profile = "${aws_iam_instance_profile.SHAEC2Profile.name}"
    monitoring = true
    tags = {
        Name = "SHAEC2"
    }
}

resource "aws_security_group" "EC2SecurityGroup" {
    description = "Security Group which allows outbound Internet and SSM access"
    name = "SHA-sg"
    tags = {
        Name = "SHA-sg"
    }
    vpc_id = module.vpc.vpc_id
    ingress {
        cidr_blocks = [
            "${var.vpc_cidr_block}"
        ]
        description = "Inbound SSH"
        from_port = 22
        protocol = "tcp"
        to_port = 22
    }
    egress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        description = "DNS resolution"
        from_port = 53
        protocol = "udp"
        to_port = 53
    }
    egress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        description = "NTP Time Sync"
        from_port = 123
        protocol = "udp"
        to_port = 123
    }
    egress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        description = "Download packages from Internet, SSM Connect, and write to S3"
        from_port = 443
        protocol = "tcp"
        to_port = 443
    }
}

resource "aws_security_group" "EndpointSecurityGroup" {
    description = "Security Group which allows access to endpoints from the VPC"
    name = "endpoint-sg"
    tags = {
        Name = "endpoint-sg"
    }
    vpc_id = module.vpc.vpc_id
    ingress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["${var.vpc_cidr_block}"]
    }
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }
}

resource "aws_launch_template" "EC2LaunchTemplate" {
    name = "SHALaunchTemplate"
}

resource "aws_sns_topic" "SNSTopic" {
    display_name = ""
    name = "SHANotifications"
}

resource "aws_sns_topic_policy" "SNSTopicPolicy" {
    policy = jsonencode ({
        Version = "2012-10-17",
        Statement = [
            {
                Sid = "Allow Local Account Publish"
                Effect = "Allow",
                Principal = {
                    Service = "events.amazonaws.com"
                },
                Action = "sns:Publish",
                Resource = "${aws_sns_topic.SNSTopic.arn}"
                Condition = {
                    StringEquals = {
                        "aws:SourceAccount" = "${local.account_id}"
                    }
                }
            }
        ]
    })
    arn = aws_sns_topic.SNSTopic.arn
}

resource "aws_sns_topic_subscription" "SNSSubscription" {
    topic_arn = aws_sns_topic.SNSTopic.arn
    endpoint  = var.notification_recipient
    protocol  = "email"
    confirmation_timeout_in_minutes = 5
}


resource "aws_cloudwatch_event_rule" "SHAS3BucketEvent" {
    name = "SHAS3BucketEvent"
    description = "SHA S3 Bucket Event"
    event_pattern = jsonencode ({
        "source": ["aws.s3"],
        "detail-type": ["Object Created"],
        "detail": {
            "bucket": {
                "name": [aws_s3_bucket.sha_output_bucket.arn]
            }
        }
    })
}

resource "aws_cloudwatch_event_target" "CloudWatchEventTarget" {
    rule = aws_cloudwatch_event_rule.SHAS3BucketEvent.name 
    arn = aws_sns_topic.SNSTopic.arn
    input_transformer {
        input_paths = {
            s3bucket = "$.detail.bucket.name"
            s3objectkey = "$.detail.object.key"
        }
        input_template = <<EOF
"SHA assessment has completed and the report has been uploaded to the S3 Bucket."
"Please download and process the findings"
"S3 Bucket Name: <s3bucket>"
"S3 Object Key: <s3objectkey>"

EOF
    }
}
