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
	azs = 
	cidr = 
	prefix = 
	suffix = 
	type = 
	vpc_id = 

	# Optional variables
	gateway_id = ""
	nat_gateway_id = ""
	tags = {}
}
```
## Resources

| Name | Type |
|------|------|
| [aws_route.internet](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/route) | resource |
| [aws_route.peering](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/route) | resource |
| [aws_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/route_table) | resource |
| [aws_route_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/route_table_association) | resource |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/subnet) | resource |
| [aws_vpc_peering_connection.pc](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/data-sources/vpc_peering_connection) | data source |
| [aws_vpc_peering_connections.inbound_pcs](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/data-sources/vpc_peering_connections) | data source |
| [aws_vpc_peering_connections.outbound_pcs](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/data-sources/vpc_peering_connections) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azs"></a> [azs](#input\_azs) | CIDR 목록에 1:1 매칭 되는 가용영역 목록 | `list(string)` | n/a | yes |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | 생성할 서브넷들의 CIDR 목록 | `list(string)` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | 서브넷 이름에 추가할 접두사 | `string` | n/a | yes |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | 서브넷 이름에 추가할 접미사 | `string` | n/a | yes |
| <a name="input_type"></a> [type](#input\_type) | 서브넷 종류 - public 또는 private | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | 서브넷을 생성할 VPC ID | `string` | n/a | yes |
| <a name="input_gateway_id"></a> [gateway\_id](#input\_gateway\_id) | 인터넷 게이트웨이 ID - 서브넷 종류가 public 일때 명시 | `string` | `""` | no |
| <a name="input_nat_gateway_id"></a> [nat\_gateway\_id](#input\_nat\_gateway\_id) | NAT 게이트웨이 ID - 서브넷 종류가 private 일때 명시 | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | 생성될 리소스에 부여할 태그 목록 | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_route_table_id"></a> [route\_table\_id](#output\_route\_table\_id) | 라우팅 테이블 ID |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | 서브넷 목록 |
<!-- END_AUTOMATED_TF_DOCS_BLOCK -->