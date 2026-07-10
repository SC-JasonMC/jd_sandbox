
# # File server IAM permissions

# resource "aws_iam_role" "ec2_managed_role" {
#     path = "/"
#     name = "pcl-fileserver-ec2-role"
#     assume_role_policy = jsonencode ({
#         Version = "2012-10-17",
#         Statement = [{
#             Effect = "Allow",
#             Principal = {
#                 Service = [
#                     "ec2.amazonaws.com",
#                     "ssm.amazonaws.com"
#                 ]
#             },
#             Action = "sts:AssumeRole"
#         }]
#     })
#     max_session_duration = 43200
#     tags = merge(
#       var.tags,
#       {

#       }
#     )
# }

# resource "aws_iam_instance_profile" "ec2_managed_profile" {
#   name = "pcl-fileserver-ec2-profile"
#   role = aws_iam_role.ec2_managed_role.name
# }

# resource "aws_iam_role_policy_attachment" "ec2_managed_policy_attach" {
#   role          = aws_iam_role.ec2_managed_role.name
#   policy_arn    = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }


# # Security Groups

# resource "aws_security_group" "test1_sg" {
#   name        = "test1-pri-sg01"
#   description = "Allow traffic to and from the file servers"
#   vpc_id      = aws_vpc.private_vpc.id

#   tags = merge(
#     var.tags,
#     {
#       Name = "test1-pri-sg01"
#     }
#   )
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_all_ingress_ipv4_aws_int" {
#   security_group_id = aws_security_group.test1_sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   ip_protocol       = "-1" # All ports/protocols
# }

# resource "aws_vpc_security_group_egress_rule" "allow_all_egress_ipv4_int" {
#   security_group_id = aws_security_group.test1_sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   ip_protocol       = "-1" # All ports/protocols
# }

# resource "aws_security_group" "test2_sg" {
#   name        = "test2-pri-sg01"
#   description = "Allow traffic to and from the file servers"
#   vpc_id      = "vpc-047027ac2ee2d1c63"

#   tags = merge(
#     var.tags,
#     {
#       Name = "test2-pri-sg01"
#     }
#   )
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_all_ingress_ipv4_aws_int_2" {
#   security_group_id = aws_security_group.test2_sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   ip_protocol       = "-1" # All ports/protocols
# }

# resource "aws_vpc_security_group_egress_rule" "allow_all_egress_ipv4_int_2" {
#   security_group_id = aws_security_group.test2_sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   ip_protocol       = "-1" # All ports/protocols
# }

# # EC2 instances

# resource "aws_instance" "test1" {
#     ami = "ami-08982f1c5bf93d976"
#     instance_type = "t2.micro"
#     tenancy = "default"
#     subnet_id = "subnet-08e81c0a1eed49906"
#     ebs_optimized = false
#     vpc_security_group_ids = [
#         "${aws_security_group.test1_sg.id}"
#     ]
#     # iam_instance_profile = "${aws_iam_instance_profile.fortigate_ec2_profile.name}"
#     iam_instance_profile =  aws_iam_instance_profile.ec2_managed_profile.id
#     key_name = "test"
#     monitoring = true
#     tags = merge(
#       var.tags,
#       {
#         Name = "test1"
#       }
#     )
# }

# resource "aws_network_interface" "test1_sec" {
#   subnet_id       = "subnet-003eee7d3682e577a"
#   security_groups = [aws_security_group.test1_sg.id]

#   attachment {
#     instance     = aws_instance.test1.id
#     device_index = 1
#   }
# }

# resource "aws_instance" "test2" {
#     ami = "ami-08982f1c5bf93d976"
#     instance_type = "t2.micro"
#     tenancy = "default"
#     subnet_id = "subnet-0a6fb93591263aa08"
#     ebs_optimized = false
#     vpc_security_group_ids = [
#         "${aws_security_group.test2_sg.id}"
#     ]
#     # iam_instance_profile = "${aws_iam_instance_profile.fortigate_ec2_profile.name}"
#     iam_instance_profile =  aws_iam_instance_profile.ec2_managed_profile.id
#     key_name = "test"
#     monitoring = true
#     tags = merge(
#       var.tags,
#       {
#       Name = "test2"
#     }
#     )
# }

# resource "aws_network_interface" "test2_sec" {
#   subnet_id       = "subnet-0cc3ec379d5178032"
#   security_groups = [aws_security_group.test2_sg.id]

#   attachment {
#     instance     = aws_instance.test2.id
#     device_index = 1
#   }
# }


# # resource "aws_fsx_windows_file_system" "signiant_fileshare" {
# #   active_directory_id = aws_directory_service_directory.example.id
# #   kms_key_id          = aws_kms_key.fsx_kms.arn 
# #   storage_capacity    = 3000
# #   subnet_ids          = [var.vpc.private_subnets[0]]
# #   throughput_capacity = 32
# # }

# # resource "aws_fsx_windows_file_system" "user_fileshare" {
# #   active_directory_id = aws_directory_service_directory.example.id
# #   kms_key_id          = aws_kms_key.fsx_kms.arn
# #   storage_capacity    = 1000
# #   subnet_ids          = [var.vpc.private_subnets[0]]
# #   throughput_capacity = 32
# # }