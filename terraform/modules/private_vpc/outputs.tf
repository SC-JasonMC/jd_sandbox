output "vpc_info" {
  value = {
    id              = aws_vpc.private_vpc.id
    cidr_block      = aws_vpc.private_vpc.cidr_block
    private_subnets = aws_subnet.private[*].id
    # private_route_table_id    = aws_route_table.private_rtb.id
  }
}

# output "tgw_attach_id" {
#   value = aws_ec2_transit_gateway_vpc_attachment.vpc_tgw_attach.id
#   description = "ID of the Networking account Transit Gateway Attachment"
# }