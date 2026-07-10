output "vpc_info" {
  value = {
    id              = aws_vpc.networking_vpc.id
    cidr_block      = aws_vpc.networking_vpc.cidr_block
    private_subnets = data.aws_subnets.private
    public_subnets  = data.aws_subnets.public
    private_route_table_id    = aws_route_table.private_rtb.id
    public_route_table_id     = aws_route_table.public_rtb.id
  }
}
