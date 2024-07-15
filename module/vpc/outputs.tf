output "vpc_id" {
  description = "생성된 VPC ID"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "퍼블릭 서브넷 목록"
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "프라이빗 서브넷 목록"
}