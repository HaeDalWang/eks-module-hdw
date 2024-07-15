variable "cluster_name" {
  description = "클러스터 이름"
  type        = string
}

variable "vpc_id" {
  description = "EKS 클러스터을 생성할 VPC의 ID"
  type        = string
}

variable "cluster_version" {
  description = "EKS 클러스터 버전"
  type        = string
}

variable "vpc_subnet_ids" {
  description = "EKS 클러스터의 ENI가 생성될 서브넷 목록"
  type        = list(string)
}

variable "cluster_endpoint_public_access" {
  description = "EKS 클러스터 Public 엔드포인트 활성화 유무"
  type        = bool
  default     = false
}

variable "cluster_endpoint_private_access" {
  description = "EKS 클러스터 Private 엔드포인트 활성화 유무"
  type        = bool
  default     = true
}

variable "authentication_mode" {
  description = "EKS 클러스터 인증 모드"
  type        = string
  default = "API_AND_CONFIG_MAP"
}

variable "tags" {
  description = "생성될 리소스에 부여할 태그 목록"
  type        = map(string)
  default     = {}
}