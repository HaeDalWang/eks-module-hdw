# NAT 게이트웨이에 부여할 고정 IP 할당
resource "aws_eip" "this" {
  vpc = true

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}

# NAT 게이트웨이 생성
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this.id
  subnet_id     = var.subnet_id

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}