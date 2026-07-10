resource "aws_vpc" "networking_vpc"{
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


resource "aws_subnet" "public" {
  count = var.public_subnets_count
  vpc_id            = aws_vpc.networking_vpc.id
  cidr_block        = cidrsubnet(
    local.vpc_cidr[local.current_account_id],
    var.public_subnets_length - tonumber(split("/", local.vpc_cidr[local.current_account_id])[1]),
    count.index
  )
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.resource_name_prefix}-public-${data.aws_availability_zones.available.names[count.index]}"
      Type = "public"
    }
  )
}

resource "aws_subnet" "private" {
  count = var.private_subnets_count

  vpc_id            = aws_vpc.networking_vpc.id
  cidr_block        = cidrsubnet(
    local.vpc_cidr[local.current_account_id],
    var.private_subnets_length - tonumber(split("/", local.vpc_cidr[local.current_account_id])[1]),
    count.index + var.public_subnets_count
  )
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.resource_name_prefix}-private-${data.aws_availability_zones.available.names[count.index]}"
      Type = "private"
    }
  )
}

# resource "aws_eip" "nat" {
#   domain = "vpc"
# }

resource "aws_nat_gateway" "natgw" {
  # allocation_id = aws_eip.nat.id 
  # subnet_id = aws_subnet.public[0].id
  vpc_id = aws_vpc.networking_vpc.id
  availability_mode = "regional"
  tags = merge(
    var.tags,
    {
      Name = "${var.resource_name_prefix}-ngw01"
    }
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.networking_vpc.id

  tags = merge(
    var.tags,
    {
      Name = "${var.resource_name_prefix}-igw01"
    }
  )
}

# Flow Logs

resource "aws_cloudwatch_log_group" "vpc_flowlog_group" {
  name = "${var.resource_name_prefix}-vpc01-flowlogs"
}

resource "aws_flow_log" "vpc_flowlog" {
  iam_role_arn    = var.vpc_flow_logs_role
  log_destination = aws_cloudwatch_log_group.vpc_flowlog_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.networking_vpc.id
}
