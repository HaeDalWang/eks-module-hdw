output "node_role" {
  description = "노드그룹에 부여된 IAM 역할"
  value       = aws_iam_role.this.name
}