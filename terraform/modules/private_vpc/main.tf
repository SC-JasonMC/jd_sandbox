resource "aws_vpc" "private_vpc"{
  cidr_block = local.vpc_cidr[local.current_account_id]
  enable_dns_support = true
  enable_dns_hostnames = true
  
  tags = merge(
    var.tags,
    {
      Name = "${var.resource_name_prefix}-vpc01"
    }
  )
}

# resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
#   vpc_id     = aws_vpc.private_vpc.id
#   cidr_block = "${local.vpc_cidr_2[local.current_account_id]}"
# }

resource "aws_subnet" "private" {
  count = var.private_subnets_count

  vpc_id            = aws_vpc.private_vpc.id
  cidr_block        = cidrsubnet(
    local.vpc_cidr[local.current_account_id],
    var.private_subnets_length - tonumber(split("/", local.vpc_cidr[local.current_account_id])[1]),
    count.index
  )
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.resource_name_prefix}-private-${data.aws_availability_zones.available.names[count.index]}"
      Type = "private"
      Routing = "local"
    }
  )
}

# resource "aws_subnet" "secondary" {
#   depends_on = [ aws_vpc_ipv4_cidr_block_association.secondary_cidr ]
#   count = var.private_subnets_count

#   vpc_id            = aws_vpc.private_vpc.id
#   cidr_block        = cidrsubnet(
#     local.vpc_cidr_2[local.current_account_id],
#     var.private_subnets_length - tonumber(split("/", local.vpc_cidr_2[local.current_account_id])[1]),
#     count.index
#   )
#   availability_zone = data.aws_availability_zones.available.names[count.index]

#   tags = merge(
#     var.tags,
#     {
#       Name = "${var.resource_name_prefix}-secondary-${data.aws_availability_zones.available.names[count.index]}"
#       Type = "private"
#       Routing = "tgw"
#     }
#   )
# }


# Flow Logs

resource "aws_cloudwatch_log_group" "vpc_flowlog_group" {
  name = "${var.resource_name_prefix}-vpc01-flowlogs"
}

resource "aws_flow_log" "vpc_flowlog" {
  iam_role_arn    = var.vpc_flow_logs_role
  log_destination = aws_cloudwatch_log_group.vpc_flowlog_group.arn
  traffic_type    = "ALL"
  vpc_id = aws_vpc.private_vpc.id
}