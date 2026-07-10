data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}


# data "aws_ec2_transit_gateway" "shared_tgw" {
#   depends_on = [aws_ram_resource_share_accepter.tgw_share_accept]
#   filter {
#     name   = "state"
#     values = ["available"]
#   }

#   filter {
#     name   = "owner-id"
#     values = [{ for acct in var.accounts : acct.name => acct }["network"].id]  # ID of the account that owns the TGW
#   }

#   filter {
#     name   = "tag:Name"
#     values = ["${var.resource_name_prefix}-network-tgw01"]  # Replace with the actual TGW name tag
#   }
# }