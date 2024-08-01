variable "cluster_name" {
  description = "cluster의 이름"
  type        = string
}

variable "node_iam_role_additional_policies" {
  description = "Node 인스턴스 프로파일에 적용할 추가적인 Policy 항목"
  type        = map(string)
  default     = {}
}

variable "irsa_oidc_provider_issuer" {
  description = "irsa 용 oidc issuer"
  type = string
}

variable "node_iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "irsa_namespace_service_accounts" {
  description = "List of `namespace:serviceaccount`pairs to use in trust policy for IAM role for service accounts"
  type        = list(string)
  default     = ["karpenter:karpenter"]
}

variable "enabled_spot_linked_role" {
  description = "spot instance 제어를 위한 AWS Service Linked Role을 생성할지 유무"
  type = bool
  default = false
}

variable "queue_name" {
  type = string
  description = "karpenter spot 인스턴스 관리를 위한 sqs"
  default = null
}