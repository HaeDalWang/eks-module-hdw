provider "aws" {
  region = local.region
}

provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
  #   exec {
  #   # AWS CLI v2를 최신 버전으로 업데이트해야 v1beta1이 동작
  #   api_version = "client.authentication.k8s.io/v1beta1"
  #   command     = "aws"
  #   /* 테라폼이 실행되는 호스트에 AWS CLI가 설치되어 있어야 하고
  #      테라폼을 실행시키는 AWS 자격증명이 EKS 클러스터에 접근 권한이 있어야 함 */
  #   args = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
  # }
}
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
    # exec {
    # api_version = "client.authentication.k8s.io/v1beta1"
    # command     = "aws"
    # args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
    # }
  }
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
  load_config_file       = false
}


data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_id
}