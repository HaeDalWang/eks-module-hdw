<!-- BEGIN_AUTOMATED_TF_DOCS_BLOCK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.30.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.13.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.0.3 |

## Usage
해당 모듈의 기본 사용법은 아래와 같습니다

```hcl
module "example" {
	source = "<module-path>"

	# Required variables
	cluster_name = 
	cluster_version = 
	vpc_id = 
	vpc_subnet_ids = 

	# Optional variables
	tags = {}
}
```
## Resources

| Name | Type |
|------|------|
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/eks_cluster) | resource |
| [aws_iam_openid_connect_provider.oidc_provider](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.eks_service_role](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.eks_service_role](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.eks_security_group](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/security_group) | resource |
| [aws_security_group_rule.from_rms_worknet_to_eks](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/security_group_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/data-sources/caller_identity) | data source |
| [aws_iam_session_context.current](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/data-sources/iam_session_context) | data source |
| [tls_certificate.this](https://registry.terraform.io/providers/hashicorp/tls/4.0.3/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | 생성할 EKS 클러스터 이름 | `string` | n/a | yes |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | EKS 클러스터 버전 | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | EKS 클러스터가 사용할 VPC | `string` | n/a | yes |
| <a name="input_vpc_subnet_ids"></a> [vpc\_subnet\_ids](#input\_vpc\_subnet\_ids) | EKS 클러스터의 ENI가 생성될 서브넷 목록 | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | 생성될 리소스에 부여할 태그 목록 | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_additional_security_group"></a> [additional\_security\_group](#output\_additional\_security\_group) | 생성된 EKS 클러스터에 추가로 부여된 보안그룹 |
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | 생성된 EKS 클러스터 CA 인증서 정보 |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | 생성된 EKS 클러스터 엔드포인트 |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | 생성된 EKS 클러스터 이름 |
| <a name="output_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#output\_cluster\_oidc\_issuer\_url) | 생성된 EKS 클러스터의 OIDC 제공자 URL |
| <a name="output_cluster_oidc_provider"></a> [cluster\_oidc\_provider](#output\_cluster\_oidc\_provider) | 생성된 EKS 클러스터의 OIDC 제공자 |
| <a name="output_cluster_security_group"></a> [cluster\_security\_group](#output\_cluster\_security\_group) | 생성된 EKS 클러스터에 부여된 보안그룹 |
| <a name="output_cluster_version"></a> [cluster\_version](#output\_cluster\_version) | 생성된 EKS 클러스터 버전 |
| <a name="output_update_kubeconfig_command"></a> [update\_kubeconfig\_command](#output\_update\_kubeconfig\_command) | 생성된 EKS 클러스터에 사용할 kubeconfig 파일 생성 명령어 |
<!-- END_AUTOMATED_TF_DOCS_BLOCK -->