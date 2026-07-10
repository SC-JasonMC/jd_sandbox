# data "aws_ami" "amzn_linux_official" {
#   most_recent = true
#   owners      = ["amazon"]
#   filter {
#     name   = "architecture"
#     values = ["x86_64"]
#   }
#   filter {
#     name   = "name"
#     values = ["al2023-ami-2023*"]
#   }
# }

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# data "aws_availability_zones" "available" {
#   state = "available"
# }

locals {
    account_id  = data.aws_caller_identity.current.account_id
    region      = data.aws_region.current.region
    # ami_id      = data.aws_ami.amzn_linux_official.id
}