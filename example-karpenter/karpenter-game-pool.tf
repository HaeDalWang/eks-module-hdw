resource "kubectl_manifest" "karpenter_game_node_class" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1
    kind: EC2NodeClass
    metadata:
      name: game
    spec:
      amiSelectorTerms:
      - alias: al2@latest
      role: ${module.karpenter.node_iam_role_name}
      subnetSelectorTerms:
      - tags:
          kubernetes.io/role/public: "1"
      securityGroupSelectorTerms:
      - id: ${module.eks.cluster_primary_security_group_id}
      blockDeviceMappings:
      - deviceName: /dev/xvda
        ebs:
          volumeSize: 40Gi
          volumeType: gp3
          encrypted: true
      metadataOptions:
        httpPutResponseHopLimit: 2 ## IMDSv2를 사용하기 위해서는 2개 노드 홉이 필요합니다
      tags:
        ${jsonencode(local.tags)}
    YAML

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "karpenter_game_nodepool" {
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      name: game
    spec:
      weight: 50
      template:
        spec:
          labels:
            karpenter.sh/node-class: "game"
          expireAfter: 720h
          requirements:
          - key: kubernetes.io/arch
            operator: In
            values: ["amd64"]
          - key: kubernetes.io/os
            operator: In
            values: ["linux"]
          - key: karpenter.sh/capacity-type
            operator: In
            values: ["on-demand","spot"]
          - key: karpenter.k8s.aws/instance-category
            operator: In
            values: ["t","c", "m", "r"]
          - key: karpenter.k8s.aws/instance-generation
            operator: Gt
            values: ["2"]
          nodeClassRef:
            apiVersion: karpenter.k8s.aws/v1beta1
            kind: EC2NodeClass
            name: "game"
            group: karpenter.k8s.aws
      limits:
        cpu: 1000
      disruption:
        consolidationPolicy: WhenEmptyOrUnderutilized ## 조건부를 적는 칸이였음! 노드가 비었거나(비데몬 파드) 사용률이 적은게 조건임 지금은
        consolidateAfter: 30s ## 조건에 부합하면 몇 시간후에 통합 가능 할꺼냐는 의미 1s드면 바로 삭제함!
  YAML

  depends_on = [
    kubectl_manifest.karpenter_game_node_class
  ]
}