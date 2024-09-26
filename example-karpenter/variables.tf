variable "eks_cluster_version" {
  description = "eks_cluster_version"
  type        = string
}

variable "karpenter_version" {
  description = "karpenter_version"
  type        = string
}

variable "karpenter_crd_version" {
  description = "karpenter_crd_version"
  type        = string
}

variable "gitlab_chart_version" {
  description = "gitlab chart version"
  type        = string
}

variable "aws_load_balancer_controller_chart_version" {
  description = "aws_load_balancer_controller_chart_version"
  type        = string
}

variable "aws_load_balancer_controller_app_version" {
  description = "aws_load_balancer_controller_app_version"
  type        = string
}

variable "metrics_server_chart_version" {
  description = "metrics_server_chart_version"
  type        = string
}

variable "external_dns_chart_version" {
  description = "external_dns_chart_version"
  type        = string
}

variable "ingress_nginx_chart_version" {
  description = "ingress_nginx_chart_version"
  type        = string
}

variable "argocd_chart_version" {
  description = "argocd_chart_version"
  type        = string
}