<!-- BEGIN_AUTOMATED_TF_DOCS_BLOCK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.30.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.6.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.13.1 |

## Usage
해당 모듈의 기본 사용법은 아래와 같습니다

```hcl
module "example" {
	source = "<module-path>"

	# Required variables
	app_version = 
	chart_version = 
	cluster_name = 
	cluster_oidc_issuer = 

	# Optional variables
	private_subnets = []
	public_subnets = []
}
```
## Resources

| Name | Type |
|------|------|
| [aws_ec2_tag.common](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/ec2_tag) | resource |
| [aws_ec2_tag.private](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/ec2_tag) | resource |
| [aws_ec2_tag.public](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/ec2_tag) | resource |
| [helm_release.this](https://registry.terraform.io/providers/hashicorp/helm/2.6.0/docs/resources/release) | resource |
| [http_http.policy_document](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_version"></a> [app\_version](#input\_app\_version) | AWS Load Balancer Controller 버전 | `string` | n/a | yes |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | AWS Load Balancer Controller 헬름 차트 버전 | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS 클러스터 이름 | `string` | n/a | yes |
| <a name="input_cluster_oidc_issuer"></a> [cluster\_oidc\_issuer](#input\_cluster\_oidc\_issuer) | EKS 클러스터 OIDC 제공자 | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | Internal ELB가 생성될 서브넷 목록 | `list(string)` | `[]` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | Internet-facing ELB가 생성될 서브넷 목록 | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END_AUTOMATED_TF_DOCS_BLOCK -->