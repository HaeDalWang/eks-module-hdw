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
	name = 
	subnet_id = 

	# Optional variables
	tags = {}
}
```
## Resources

| Name | Type |
|------|------|
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/eip) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/nat_gateway) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | NAT Gateway 이름 | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | NAT Gateway를 생성할 서브넷 ID | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | 생성될 리소스에 부여할 태그 목록 | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | 생성된 NAT Gateway ID |
<!-- END_AUTOMATED_TF_DOCS_BLOCK -->