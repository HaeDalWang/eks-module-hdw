output "cluster_id" {
  description = "생성된 EKS 클러스터 이름"
  value       = aws_eks_cluster.this.id
}

output "cluster_endpoint" {
  description = "생성된 EKS 클러스터 엔드포인트"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "생성된 EKS 클러스터 CA 인증서 정보"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_oidc_issuer_url" {
  description = "생성된 EKS 클러스터의 OIDC 제공자 URL"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "cluster_oidc_provider" {
  description = "생성된 EKS 클러스터의 OIDC 제공자"
  value       = replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
}

output "cluster_security_group" {
  description = "생성된 EKS 클러스터에 부여된 보안그룹"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "additional_security_group" {
  description = "생성된 EKS 클러스터에 추가로 부여된 보안그룹"
  value       = aws_security_group.eks_security_group.id
}

output "update_kubeconfig_command" {
  description = "생성된 EKS 클러스터에 사용할 kubeconfig 파일 생성 명령어"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.this.id} --role-arn ${data.aws_iam_session_context.current.issuer_arn}"
}

output "cluster_version" {
  description = "생성된 EKS 클러스터 버전"
  value       = aws_eks_cluster.this.version
}
