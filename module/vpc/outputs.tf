output "vpc_id" {
  description = "생성된 VPC ID"
  value       = aws_vpc.this.id
}

output "igw_id" {
  description = "생성된 인터넷 게이트웨이 ID"
  value       = aws_internet_gateway.this.id
}