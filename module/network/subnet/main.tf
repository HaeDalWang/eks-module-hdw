# 서브넷 생성
resource "aws_subnet" "this" {
  count = length(var.cidr)

  vpc_id                  = var.vpc_id
  cidr_block              = var.cidr[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = var.type == "public" ? true : false

  tags = merge(
    {
      "Name" = format(
        "${var.prefix}-${var.suffix}-%s",
        substr(element(var.azs, count.index), -1, 1),
      )
    },
    var.tags
  )
}

# 라우팅 테이블 생성
resource "aws_route_table" "this" {

  vpc_id = var.vpc_id

  tags = merge(
    {
      "Name" = "${var.prefix}-${var.suffix}"
    },
    var.tags
  )
}

# 라우팅 테이블을 각 서브넷에 연동
resource "aws_route_table_association" "this" {
  count = length(var.cidr)

  subnet_id      = aws_subnet.this[count.index].id
  route_table_id = aws_route_table.this.id
}

# 서브넷 종류에 따라 NAT 또는 IGW로 가는 경로 추가
resource "aws_route" "internet" {
  route_table_id         = aws_route_table.this.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.type == "public" ? var.gateway_id : null
  nat_gateway_id         = var.type == "private" ? var.nat_gateway_id : null
}