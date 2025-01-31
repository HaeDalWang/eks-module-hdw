# Karpenter 기본 노드 클래스
resource "kubectl_manifest" "karpenter_default_node_class" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1beta1
    kind: EC2NodeClass
    metadata:
      name: default
    spec:
      amiFamily: AL2
      amiSelectorTerms:
      - id: "ami-00bb0fafaa7de9f05"
      role: ${module.karpenter.node_iam_role_name}
      subnetSelectorTerms:
      - tags:
          karpenter.sh/discovery: ${module.eks.cluster_id}
      securityGroupSelectorTerms:
      - id: ${module.eks.cluster_primary_security_group_id}
      blockDeviceMappings:
      - deviceName: /dev/xvda
        ebs:
          volumeSize: 20Gi
          volumeType: gp3
          encrypted: true
      tags:
        ${jsonencode(local.tags)}
    YAML

  depends_on = [
    helm_release.karpenter
  ]
}

# Karpenter 기본 노드 풀
resource "kubectl_manifest" "karpenter_default_nodepool" {
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1beta1
    kind: NodePool
    metadata:
      name: default
    spec:
      weight: 50
      template:
        spec:
          requirements:
          - key: kubernetes.io/arch
            operator: In
            values: ["amd64"]
          - key: kubernetes.io/os
            operator: In
            values: ["linux"]
          - key: karpenter.sh/capacity-type
            operator: In
            values: ["on-demand"]
          - key: node.kubernetes.io/instance-type
            operator: In
            values: [
              "t3.medium", "t3a.medium",
              "c5.large", "c5a.large", "c6a.large",
              "c5.xlarge", "c5a.xlarge", "c6a.xlarge"
            ]
          nodeClassRef:
            apiVersion: karpenter.k8s.aws/v1beta1
            kind: EC2NodeClass
            name: default
      limits:
        cpu: 2400
      disruption:
        consolidationPolicy: WhenUnderutilized
        expireAfter: 720h
  YAML

  depends_on = [
    kubectl_manifest.karpenter_default_node_class
  ]

  # 만약 재성성이 필요할 경우 먼저 리소스 생성 후 삭제하도록 순서보장
  lifecycle {
    create_before_destroy = true
  }
}

######################## 1.0.0
# ## NodeClass

# resource "kubectl_manifest" "karpenter_default_node_class" {
#   yaml_body = <<-YAML
#     apiVersion: karpenter.k8s.aws/v1
#     kind: EC2NodeClass
#     metadata:
#       name: default
#     spec:
#       amiSelectorTerms:
#       - alias: al2@latest
#       role: ${module.karpenter.node_iam_role_name}
#       subnetSelectorTerms:
#       - tags:
#           karpenter.sh/discovery: ${module.eks.cluster_id}
#       securityGroupSelectorTerms:
#       - id: ${module.eks.cluster_primary_security_group_id}
#       blockDeviceMappings:
#       - deviceName: /dev/xvda
#         ebs:
#           volumeSize: 40Gi
#           volumeType: gp3
#           encrypted: true
#       metadataOptions:
#         httpPutResponseHopLimit: 2 ## IMDSv2를 사용하기 위해서는 2개 노드 홉이 필요합니다
#       tags:
#         ${jsonencode(local.tags)}
#     YAML

#   depends_on = [
#     helm_release.karpenter
#   ]
# }

# ## Node Pool
# resource "kubectl_manifest" "karpenter_default_nodepool" {
#   yaml_body = <<-YAML
#     apiVersion: karpenter.sh/v1
#     kind: NodePool
#     metadata:
#       name: default
#     spec:
#       weight: 50
#       template:
#         spec:
#           expireAfter: 720h
#           requirements:
#           - key: kubernetes.io/arch
#             operator: In
#             values: ["amd64"]
#           - key: kubernetes.io/os
#             operator: In
#             values: ["linux"]
#           - key: karpenter.sh/capacity-type
#             operator: In
#             values: ["on-demand","spot"]
#           - key: karpenter.k8s.aws/instance-category
#             operator: In
#             values: ["t","c", "m", "r"]
#           - key: karpenter.k8s.aws/instance-generation
#             operator: Gt
#             values: ["2"]
#           nodeClassRef:
#             apiVersion: karpenter.k8s.aws/v1
#             kind: EC2NodeClass
#             name: "default"
#             group: karpenter.k8s.aws
#       limits:
#         cpu: 1000
#       disruption:
#         consolidationPolicy: WhenEmptyOrUnderutilized ## 조건부를 적는 칸이였음! 노드가 비었거나(비데몬 파드) 사용률이 적은게 조건임 지금은
#         consolidateAfter: 30s ## 조건에 부합하면 몇 시간후에 통합 가능 할꺼냐는 의미 1s드면 바로 삭제함!
#   YAML

#   depends_on = [
#     kubectl_manifest.karpenter_default_node_class
#   ]
# }