output "serviceaccount_name" {
  description = "생성된 서비스 어카운트 이름"
  value       = !var.create_iam_role_only ? kubernetes_service_account.this[0].metadata[0].name : null
}

output "role_arn" {
  description = "서비스 어카운트에 연동된 IAM 역할 ARN"
  value       = aws_iam_role.this.arn
}