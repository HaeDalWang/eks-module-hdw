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
	aws_load_balancer_controller_app_version = 
	aws_load_balancer_controller_chart_version = 
	cluster_autoscaler_chart_version = 
	cluster_name = 
	cluster_oidc_issuer = 
	external_dns_chart_version = 
	external_dns_role_arn = 
	metric_server_chart_version = 
	nginx_ingress_controller_chart_version = 

	# Optional variables
	acm_certificate_arn = ""
	external_dns_domain_filters = []
	hostedzone_type = ""
	private_subnet_ids = []
	public_subnet_ids = []
}
```
## Resources

| Name | Type |
|------|------|
| [helm_release.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.external_dns](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.metric_server](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.nginx_ingress_controller](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_load_balancer_controller_app_version"></a> [aws\_load\_balancer\_controller\_app\_version](#input\_aws\_load\_balancer\_controller\_app\_version) | AWS Load Balancer Controller 버전 | `string` | n/a | yes |
| <a name="input_aws_load_balancer_controller_chart_version"></a> [aws\_load\_balancer\_controller\_chart\_version](#input\_aws\_load\_balancer\_controller\_chart\_version) | AWS Load Balancer Controller 헬름 차트 버전 | `string` | n/a | yes |
| <a name="input_cluster_autoscaler_chart_version"></a> [cluster\_autoscaler\_chart\_version](#input\_cluster\_autoscaler\_chart\_version) | Cluster Autoscaler 헬름 차트 버전 | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS 클러스터 이름 | `string` | n/a | yes |
| <a name="input_cluster_oidc_issuer"></a> [cluster\_oidc\_issuer](#input\_cluster\_oidc\_issuer) | EKS 클러스터 OIDC 제공자 | `string` | n/a | yes |
| <a name="input_external_dns_chart_version"></a> [external\_dns\_chart\_version](#input\_external\_dns\_chart\_version) | External DNS 차트 버전 | `string` | n/a | yes |
| <a name="input_external_dns_role_arn"></a> [external\_dns\_role\_arn](#input\_external\_dns\_role\_arn) | External DNS에서 부여할 IAM 역할 ARN | `string` | n/a | yes |
| <a name="input_metric_server_chart_version"></a> [metric\_server\_chart\_version](#input\_metric\_server\_chart\_version) | Metric Server 헬름 차트 버전 | `string` | n/a | yes |
| <a name="input_nginx_ingress_controller_chart_version"></a> [nginx\_ingress\_controller\_chart\_version](#input\_nginx\_ingress\_controller\_chart\_version) | NGINX Ingress Controller 차트 버전 | `string` | n/a | yes |
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | Ingress Controller를 통해서 생성되는 NLB/ALB에 반영할 ACM 인증서 | `string` | `""` | no |
| <a name="input_external_dns_domain_filters"></a> [external\_dns\_domain\_filters](#input\_external\_dns\_domain\_filters) | External DNS에서 DNS 레코드를 생성할 도메인 주소 목록 | `list(string)` | `[]` | no |
| <a name="input_hostedzone_type"></a> [hostedzone\_type](#input\_hostedzone\_type) | External DNS에서 연동한 Route53 Hosted Zone 종류 | `string` | `""` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Internal ELB가 생성될 서브넷 목록 | `list(string)` | `[]` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | Internet-facing ELB가 생성될 서브넷 목록 | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END_AUTOMATED_TF_DOCS_BLOCK -->