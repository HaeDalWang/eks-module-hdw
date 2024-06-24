<!-- BEGIN_AUTOMATED_TF_DOCS_BLOCK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.30.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.13.1 |

## Usage
해당 모듈의 기본 사용법은 아래와 같습니다

```hcl
module "example" {
	source = "<module-path>"

	# Required variables
	cluster_name = 
	cluster_oidc_issuer = 
	name = 

	# Optional variables
	create_iam_role_only = false
	managed_policy_arns = []
	namespace = "default"
	policy_document = ""
}
```
## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/iam_role) | resource |
| [kubernetes_service_account.this](https://registry.terraform.io/providers/hashicorp/kubernetes/2.13.1/docs/resources/service_account) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS 클러스터 이름 | `string` | n/a | yes |
| <a name="input_cluster_oidc_issuer"></a> [cluster\_oidc\_issuer](#input\_cluster\_oidc\_issuer) | EKS 클러스터 OIDC 제공자 | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | 서비스 어카운트 이름 | `string` | n/a | yes |
| <a name="input_create_iam_role_only"></a> [create\_iam\_role\_only](#input\_create\_iam\_role\_only) | ServiceAccount에 부여할 역할만 생성 | `bool` | `false` | no |
| <a name="input_managed_policy_arns"></a> [managed\_policy\_arns](#input\_managed\_policy\_arns) | ServiceAccount에 부여할 AWS 관리형 적책 목록 | `list(string)` | `[]` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | 서비스 어카운트를 생성할 네임스페이스 이름 | `string` | `"default"` | no |
| <a name="input_policy_document"></a> [policy\_document](#input\_policy\_document) | IAM 정책 문서 | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | 서비스 어카운트에 연동된 IAM 역할 ARN |
| <a name="output_serviceaccount_name"></a> [serviceaccount\_name](#output\_serviceaccount\_name) | 생성된 서비스 어카운트 이름 |
<!-- END_AUTOMATED_TF_DOCS_BLOCK -->