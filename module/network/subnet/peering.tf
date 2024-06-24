# Subnet이 생성된 VPC에서 요청한 Peering 목록 불러오기
data "aws_vpc_peering_connections" "outbound_pcs" {
  filter {
    name   = "requester-vpc-info.vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "status-code"
    values = ["active"]
  }
}

# Subnet이 생성된 VPC에서 수락한 Peering 목록 불러오기
data "aws_vpc_peering_connections" "inbound_pcs" {
  filter {
    name   = "accepter-vpc-info.vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "status-code"
    values = ["active"]
  }
}

# Subnet이 생성된 VPC에 연결된 모든 Peering 목록
data "aws_vpc_peering_connection" "pc" {
  for_each = toset(concat(data.aws_vpc_peering_connections.outbound_pcs.ids, data.aws_vpc_peering_connections.inbound_pcs.ids))
  id       = each.key
}

# Subnet에 부여된 라우팅 테이블에 각각의 Peering으로 가는 Route 생성
resource "aws_route" "peering" {
  for_each                  = data.aws_vpc_peering_connection.pc
  route_table_id            = aws_route_table.this.id
  destination_cidr_block    = each.value.vpc_id == var.vpc_id ? each.value.peer_cidr_block : each.value.cidr_block
  vpc_peering_connection_id = each.value.id
}