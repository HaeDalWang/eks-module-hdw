variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
}

variable "cluster_version" {
  description = "클러스터 버전"
  type        = string
}

variable "pod_identity_enabled" {
  description = "Pod_Identity  Addon 활성화 여부"
  type        = bool
  default     = false
}

variable "cluster_oidc_issuer" {
  description = "EKS 클러스터 OIDC 제공자"
  type        = string
}

variable "public_subnet_ids" {
  description = "Internet-facing ELB가 생성될 서브넷 목록"
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "Internal ELB가 생성될 서브넷 목록"
  type        = list(string)
  default     = []
}

variable "enabled_metric_server" {
  description = "Metric Server 활성화 여부"
  type        = bool
  default     = false
}

variable "metric_server_chart_version" {
  description = "Metric Server 헬름 차트 버전"
  type        = string
  default     = []
}

variable "enabled_cluster_autoscaler" {
  description = "Cluster_autoscaler 활성화 여부"
  type        = bool
  default     = false
}

variable "cluster_autoscaler_chart_version" {
  description = "Cluster Autoscaler 헬름 차트 버전"
  type        = string
  default     = []
}

variable "enabled_aws_load_balancer_controller" {
  description = "AWS Load Balancer Controller 활성화 여부"
  type        = bool
  default     = false
}

variable "aws_load_balancer_controller_chart_version" {
  description = "AWS Load Balancer Controller 헬름 차트 버전 "
  type        = string
}

variable "aws_load_balancer_controller_app_version" {
  description = "AWS Load Balancer Controller 버전 "
  type        = string
}

variable "enabled_external_dns" {
  description = "external dns 활성화 여부"
  type        = bool
  default     = false
}

variable "external_dns_chart_version" {
  description = "External DNS 차트 버전"
  type        = string
  default     = []
}

variable "external_dns_domain_filters" {
  description = "External DNS에서 DNS 레코드를 생성할 도메인 주소 목록"
  type        = list(string)
  default     = [""]
}

variable "hostedzone_type" {
  description = "External DNS에서 연동한 Route53 Hosted Zone 종류"
  type        = string
  default     = ""
}

# variable "enabled_nginx_ingress_controller" {
#   description = "enabled_nginx_ingress_controller"
#   type = bool
#   default = false
# }

# variable "nginx_ingress_controller_chart_version" {
#   description = "NGINX Ingress Controller 차트 버전"
#   type        = string
# }

# variable "acm_certificate_arn" {
#   description = "Ingress Controller를 통해서 생성되는 NLB/ALB에 반영할 ACM 인증서"
#   type        = string
#   default     = ""
# }