output "iam_role_arn" {
  description = "Instance Profile에 필요한 Role ARN"
  value = aws_iam_role.controller.arn
}

output "queue_name" {
  description = "karpenter가 사용할 SQS 이름"
  value = aws_sqs_queue.this.id
}