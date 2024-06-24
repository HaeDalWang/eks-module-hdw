variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
}

variable "cluster_oidc_issuer" {
  description = "EKS 클러스터 OIDC 제공자"
  type        = string
}

variable "chart_version" {
  description = "AWS Load Balancer Controller 헬름 차트 버전 "
  type        = string
}

variable "app_version" {
  description = "AWS Load Balancer Controller 버전 "
  type        = string
}

variable "public_subnets" {
  description = "Internet-facing ELB가 생성될 서브넷 목록"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "Internal ELB가 생성될 서브넷 목록"
  type        = list(string)
  default     = []
}