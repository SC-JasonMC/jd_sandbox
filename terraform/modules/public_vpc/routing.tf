resource "aws_route_table" "private_rtb" {
    vpc_id = aws_vpc.networking_vpc.id
    tags = merge(
      var.tags,
      {
        Name = "${var.resource_name_prefix}-private"
      }
    )
}

resource "aws_route_table_association" "private" {
  for_each = { for idx, subnet in aws_subnet.private : idx => subnet.id }
  subnet_id      = each.value
  route_table_id = aws_route_table.private_rtb.id
}

resource "aws_route" "private_default_route" {
  depends_on = [aws_ec2_transit_gateway_vpc_attachment.vpc_tgw_attach]
  route_table_id         = aws_route_table.private_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.natgw.id
}

resource "aws_route_table" "public_rtb" {
    vpc_id = aws_vpc.networking_vpc.id
    tags = merge(
      var.tags,
      {
        Name = "${var.resource_name_prefix}-public"
      }
    )
}

resource "aws_route_table_association" "public" {
  for_each = { for idx, subnet in aws_subnet.public : idx => subnet.id }
  subnet_id      = each.value
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route" "public_default_route" {
  depends_on = [aws_ec2_transit_gateway_vpc_attachment.vpc_tgw_attach]
  route_table_id         = aws_route_table.public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id =   aws_internet_gateway.igw.id
}


# Member account routes

resource "aws_route" "public_tgw_routes" {
  depends_on = [aws_ec2_transit_gateway_vpc_attachment.vpc_tgw_attach]
  for_each = {
    for a in var.accounts : a.name => a
    if a.name != "${local.account_name[local.current_account_id]}"  # skip current VPC
  }
  route_table_id         = aws_route_table.public_rtb.id
  destination_cidr_block = each.value.cidr
  transit_gateway_id     = aws_ec2_transit_gateway.vpc_tgw.id
}

resource "aws_route" "private_tgw_routes" {
  depends_on = [aws_ec2_transit_gateway_vpc_attachment.vpc_tgw_attach]
  for_each = {
    for a in var.accounts : a.name => a
    if a.name != "${local.account_name[local.current_account_id]}"  # skip current VPC
  }
  route_table_id         = aws_route_table.private_rtb.id
  destination_cidr_block = each.value.cidr
  transit_gateway_id     = aws_ec2_transit_gateway.vpc_tgw.id
}
