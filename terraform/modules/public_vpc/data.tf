data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

data "aws_route_tables" "private" {
  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

data "aws_route_tables" "public" {
  filter {
    name   = "tag:Type"
    values = ["public"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:Type"
    values = ["public"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

