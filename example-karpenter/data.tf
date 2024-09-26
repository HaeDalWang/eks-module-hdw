# Terraform을 실행한 AWS 자격증명 정보 받아오기
data "aws_caller_identity" "current" {}

# us-east-1 전용 권한 ECR 레포용
data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}

# Route53 호스트존
data "aws_route53_zone" "seungdobae" {
  name = "seungdobae.com."
}

