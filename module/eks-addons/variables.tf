variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
}

variable "cluster_version" {
  description = "EKS 클러스터 버전"
  type        = string
}

variable "cluster_oidc_issuer" {
  description = "EKS 클러스터 OIDC 제공자"
  type        = string
}

variable "coredns_configuration_values" {
  description = "coredns 설정"
  type        = any
  default = {}
}

variable "enabled_coredns" {
  description = "coreDNS 활성화 유무"
  type = bool
  default = true
}

