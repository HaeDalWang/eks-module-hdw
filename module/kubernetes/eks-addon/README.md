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
	coredns_version = 
	ebs_csi_driver_version = 
	vpc_cni_version = 
}
```
## Resources

| Name | Type |
|------|------|
| [aws_eks_addon.coredns](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/eks_addon) | resource |
| [aws_eks_addon.ebs_csi_controller](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/eks_addon) | resource |
| [aws_eks_addon.vpc_cni](https://registry.terraform.io/providers/hashicorp/aws/4.30.0/docs/resources/eks_addon) | resource |
| [kubernetes_annotations.default_storageclass](https://registry.terraform.io/providers/hashicorp/kubernetes/2.13.1/docs/resources/annotations) | resource |
| [kubernetes_storage_class.ebs_sc](https://registry.terraform.io/providers/hashicorp/kubernetes/2.13.1/docs/resources/storage_class) | resource |
| [kubernetes_storage_class.ebs_sc_retain](https://registry.terraform.io/providers/hashicorp/kubernetes/2.13.1/docs/resources/storage_class) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS 클러스터 이름 | `string` | n/a | yes |
| <a name="input_cluster_oidc_issuer"></a> [cluster\_oidc\_issuer](#input\_cluster\_oidc\_issuer) | EKS 클러스터 OIDC 제공자 | `string` | n/a | yes |
| <a name="input_coredns_version"></a> [coredns\_version](#input\_coredns\_version) | CoreDNS 버전 | `string` | n/a | yes |
| <a name="input_ebs_csi_driver_version"></a> [ebs\_csi\_driver\_version](#input\_ebs\_csi\_driver\_version) | Amazon EBS CSI driver 버전 | `string` | n/a | yes |
| <a name="input_vpc_cni_version"></a> [vpc\_cni\_version](#input\_vpc\_cni\_version) | VPC CNI 버전 | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_AUTOMATED_TF_DOCS_BLOCK -->