variable "name" {
  description = "서비스 어카운트 이름"
  type        = string
}

variable "namespace" {
  description = "서비스 어카운트를 생성할 네임스페이스 이름"
  type        = string
  default     = "default"
}

variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
}

variable "cluster_oidc_issuer" {
  description = "EKS 클러스터 OIDC 제공자"
  type        = string
}

variable "policy_document" {
  description = "IAM 정책 문서"
  type        = string
  default     = ""
}

variable "managed_policy_arns" {
  description = "ServiceAccount에 부여할 AWS 관리형 적책 목록"
  type        = list(string)
  default     = []
}

variable "create_iam_role_only" {
  description = "ServiceAccount에 부여할 역할만 생성"
  type        = bool
  default     = false
}