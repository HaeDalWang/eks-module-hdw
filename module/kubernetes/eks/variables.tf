variable "cluster_name" {
  description = "생성할 EKS 클러스터 이름"
  type        = string
}

variable "cluster_version" {
  description = "EKS 클러스터 버전"
  type        = string
}

variable "vpc_id" {
  description = "EKS 클러스터가 사용할 VPC"
  type        = string
}

variable "vpc_subnet_ids" {
  description = "EKS 클러스터의 ENI가 생성될 서브넷 목록"
  type        = list(string)
}

variable "tags" {
  description = "생성될 리소스에 부여할 태그 목록"
  type        = map(string)
  default     = {}
}