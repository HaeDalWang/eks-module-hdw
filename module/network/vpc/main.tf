# VPC 생성
resource "aws_vpc" "this" {
  cidr_block = var.cidr
  enable_dns_hostnames = true

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}

# IGW 생성
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}