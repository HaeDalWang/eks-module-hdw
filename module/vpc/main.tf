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

# 퍼블릭 서브넷 생성
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(concat(var.public_subnets, [""]), count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    {
      "Name" = format(
        "${var.name}-public-%s",
        substr(element(var.azs, count.index), -1, 1),
      )
    },
    var.tags,
    var.public_subnet_tags
  )
}

# 라우팅 테이블 생성
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = "${var.name}-public"
    },
    var.tags
  )
}

# 서브넷 라우팅 테이블 연결
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# IGW로 가는 경로 추가
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# 프라이빗 서브넷 생성
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(concat(var.private_subnets, [""]), count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false

  tags = merge(
    {
      "Name" = format(
        "${var.name}-private-%s",
        substr(element(var.azs, count.index), -1, 1),
      )
    },
    var.tags,
    var.private_subnet_tags
  )
}

# 라우팅 테이블 생성
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = "${var.name}-private"
    },
    var.tags
  )
}

# 서브넷 라우팅 테이블 연결
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# NAT로 가는 경로 추가
resource "aws_route" "private_internet" {
  count = var.nat_gateway_enabled ? 1 : 0
  
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id

  depends_on = [aws_nat_gateway.this]
}

# NAT 게이트웨이에 부여할 고정 IP 할당
resource "aws_eip" "nat" {
  count = var.nat_gateway_enabled ? 1 : 0

  domain = "vpc"

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
  
  depends_on = [aws_vpc.this]
}

# NAT 게이트웨이 생성
resource "aws_nat_gateway" "this" {
  count = var.nat_gateway_enabled ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
  
  depends_on = [aws_internet_gateway.this]
}