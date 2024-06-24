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
	cidr = 
	name = 

	# Optional variables
	tags = {}
}
```
## Resources

| Name | Type |
|------|------|
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/internet_gateway) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr"></a> [cidr](#input\_cidr) | VPC CIDR | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | VPC 이름 | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | 생성될 리소스에 부여할 태그 목록 | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_igw_id"></a> [igw\_id](#output\_igw\_id) | 생성된 인터넷 게이트웨이 ID |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | 생성된 VPC ID |
<!-- END_AUTOMATED_TF_DOCS_BLOCK -->