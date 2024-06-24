output "subnet_ids" {
  value       = aws_subnet.this[*].id
  description = "서브넷 목록"
}

output "route_table_id" {
  value       = aws_route_table.this.id
  description = "라우팅 테이블 ID"
}