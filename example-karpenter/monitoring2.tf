# 프로메테우스 네임스페이스
resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
      name = "monitoring"
  }
}

resource "helm_release" "kube-prometheus-stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "48.6.0"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name
  values = [templatefile("${path.module}/helm-values/kube-prometheus.yaml", {
      grafana_admin_password              = "root1234"
  })]
}