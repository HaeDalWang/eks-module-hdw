<!-- BEGIN_AUTOMATED_TF_DOCS_BLOCK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.30.0 |

## Usage
해당 모듈의 기본 사용법은 아래와 같습니다

```hcl
module "example" {
	source = "<module-path>"

	# Required variables
	cluster_name = 
	instance_types = 
	name = 
	subnet_ids = 

	# Optional variables
	cluster_version = null
	max_size = 10
	min_size = 1
	tags = {}
	user_data = ""
}
```
## Resources

| Name | Type |
|------|------|
| [aws_eks_node_group.this](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/eks_node_group) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this-AmazonEC2ContainerRegistryReadOnly](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this-AmazonEKSWorkerNodePolicy](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this-AmazonEKS_CNI_Policy](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this-AmazonSSMManagedInstanceCore](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/launch_template) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | 노드그룹이 생성될 EKS 클러스터 이름 | `string` | n/a | yes |
| <a name="input_instance_types"></a> [instance\_types](#input\_instance\_types) | 노드그룹에서 사용할 인스턴스 종류 목록 | `list(string)` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | 노드그룹 이름 | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | 노드그룹을 통해서 생성된 노드들이 위치할 서브넷 목록 | `list(string)` | n/a | yes |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | EKS 클러스터 버전 | `string` | `null` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | 노드그룹의 최대 노드 갯수 | `number` | `10` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | 노드그룹의 최소 노드 갯수 | `number` | `1` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | 태그 목록 | `map(string)` | `{}` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | 노드가 초기에 생성될때 실행할 스크립트 | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_node_role"></a> [node\_role](#output\_node\_role) | 노드그룹에 부여된 IAM 역할 |
<!-- END_AUTOMATED_TF_DOCS_BLOCK -->