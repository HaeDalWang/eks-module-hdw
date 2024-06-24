# 요구되는 테라폼 제공자 목록
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.1.0"
    }
  }
}

locals {
  ## VPC,subnet, 등에 사용
  name = "haedalwang"
  ## EKS Cluster 이름
  cluster_name = "haedalwang"

  region      = "ap-northeast-2"
  account_id  = data.aws_caller_identity.current.account_id
  environment = "dev"

  tags = {
    Terraform = "true"
  }
}

# Terraform을 실행한 AWS 자격증명 정보 받아오기
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "azs" {}