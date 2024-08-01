data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.name
}

################################################################################
# Karpener Controller IRSA
# 카펜터가 컨트롤러을 위한 권한 ServiceAccount 생성
################################################################################

## Policy 작성 생성
## karpenter CloudForamtion 예제를 참조하여 작성되었습니다
## https://karpenter.sh/docs/reference/cloudformation/#karpentercontrollerpolicy
data "aws_iam_policy_document" "karpenter_policy" {

  ##  RunInstances 및 CreateFleet 작업 으로 액세스할 수 있는 EC2 리소스 집합을 식별합니다 . 
   statement {
    sid = "AllowScopedEC2InstanceActions"
    resources = [
      "arn:${local.partition}:ec2:*::image/*",
      "arn:${local.partition}:ec2:*::snapshot/*",
      "arn:${local.partition}:ec2:*:*:spot-instances-request/*",
      "arn:${local.partition}:ec2:*:*:security-group/*",
      "arn:${local.partition}:ec2:*:*:subnet/*",
      "arn:${local.partition}:ec2:*:*:launch-template/*",
    ]

    actions = [
      "ec2:RunInstances",
      "ec2:CreateFleet"
    ]
  }
  
  ## Karpenter가 단일 EKS 클러스터에 대한 인스턴스만 생성할 수 있습니다.
  statement {
    sid = "AllowScopedEC2InstanceActionsWithTags"
    resources = [
      "arn:${local.partition}:ec2:*:*:fleet/*",
      "arn:${local.partition}:ec2:*:*:instance/*",
      "arn:${local.partition}:ec2:*:*:volume/*",
      "arn:${local.partition}:ec2:*:*:network-interface/*",
      "arn:${local.partition}:ec2:*:*:launch-template/*",
      "arn:${local.partition}:ec2:*:*:spot-instances-request/*",
    ]
    actions = [
      "ec2:RunInstances",
      "ec2:CreateFleet",
      "ec2:CreateLaunchTemplate"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/karpenter.sh/nodepool"
      values   = ["*"]
    }
  }
  
  ## karpenter가 생성한 리소스에 대해 태깅을 가능하게 합니다
  statement {
    sid = "AllowScopedResourceCreationTagging"
    resources = [
      "arn:${local.partition}:ec2:*:*:fleet/*",
      "arn:${local.partition}:ec2:*:*:instance/*",
      "arn:${local.partition}:ec2:*:*:volume/*",
      "arn:${local.partition}:ec2:*:*:network-interface/*",
      "arn:${local.partition}:ec2:*:*:launch-template/*",
      "arn:${local.partition}:ec2:*:*:spot-instances-request/*",
    ]
    actions = ["ec2:CreateTags"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values = [
        "RunInstances",
        "CreateFleet",
        "CreateLaunchTemplate",
      ]
    }

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/karpenter.sh/nodepool"
      values   = ["*"]
    }
  }

  ## Karpenter가 "karpenter.sh/nodepool" 및 태그를 통해서만 작업 중인 클러스터 인스턴스의 태그를 업데이트할 수 있도록 강제합니다
  statement {
    sid       = "AllowScopedResourceTagging"
    resources = ["arn:${local.partition}:ec2:*:*:instance/*"]
    actions   = ["ec2:CreateTags"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.sh/nodepool"
      values   = ["*"]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "aws:TagKeys"
      values = [
        "karpenter.sh/nodeclaim",
        "Name",
      ]
    }
  }

  ## Karpenter가 연관된 인스턴스 및 launch 템플릿만 삭제할 수 있습니다
  statement {
    sid = "AllowScopedDeletion"
    resources = [
      "arn:${local.partition}:ec2:*:*:instance/*",
      "arn:${local.partition}:ec2:*:*:launch-template/*"
    ]

    actions = [
      "ec2:TerminateInstances",
      "ec2:DeleteLaunchTemplate"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.sh/nodepool"
      values   = ["*"]
    }
  }

  ##  Karpenter 컨트롤러는 해당 AWS 지역의 모든 관련 리소스에서 이러한 읽기 전용 작업을 수행할 수 있습니다.
  statement {
    sid       = "AllowRegionalReadActions"
    resources = ["*"]
    actions = [
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSpotPriceHistory",
      "ec2:DescribeSubnets"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [local.region]
    }
  }

  ## SSM parameter와 리소스 비용의 대한 정보를 가저올 수 있습니다
  statement {
    sid       = "AllowSSMReadActions"
    resources = ["*"]
    actions   = ["ssm:GetParameter"]
  }
  statement {
    sid       = "AllowPricingReadActions"
    resources = ["*"]
    actions   = ["pricing:GetProducts"]
  }

  ## Karpenter 컨트롤러가 SQS 메시지에 대해 삭제/전달/받기 등을 수행 할 수 있습니다
  statement {
      sid       = "AllowInterruptionQueueActions"
      resources = ["${aws_sqs_queue.this.arn}"]
      actions = [
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:ReceiveMessage"
      ]
  }

  ## 생성한 노드의 인스턴스 프로파일(Role)을 할당하기 위해 필요합니다
  statement {
    sid       = "AllowPassingInstanceRole"
    resources = ["${aws_iam_role.node.arn}"]
    actions   = ["iam:PassRole"]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ec2.amazonaws.com"]
    }
  }

  ##  ec2nodeclass에 지정된 역할에 따라 사용자를 대신하여 인스턴스 프로필을 생성할 수 있습니다.
  statement {
    sid       = "AllowScopedInstanceProfileCreationActions"
    resources = ["*"]
    actions   = ["iam:CreateInstanceProfile"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/topology.kubernetes.io/region"
      values   = [local.region]
    }

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass"
      values   = ["*"]
    }
  }

  ## Karpenter가 클러스터에 대해 프로비저닝하는 인스턴스 프로필에서만 태깅 작업할 수 있습니다.
  statement {
    sid       = "AllowScopedInstanceProfileTagActions"
    resources = ["*"]
    actions   = ["iam:TagInstanceProfile"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/topology.kubernetes.io/region"
      values   = [local.region]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/topology.kubernetes.io/region"
      values   = [local.region]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass"
      values   = ["*"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass"
      values   = ["*"]
    }
  }

  ## karpenter가 인스턴스 프로필을 추가/부여/삭제 할 수 있습니다
  statement {
    sid       = "AllowScopedInstanceProfileActions"
    resources = ["*"]
    actions = [
      "iam:AddRoleToInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:DeleteInstanceProfile"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/topology.kubernetes.io/region"
      values   = [local.region]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass"
      values   = ["*"]
    }
  }

  ## 인스턴스 프로필 항목을 읽을 수 있습니다
  statement {
    sid       = "AllowInstanceProfileReadActions"
    resources = ["*"]
    actions   = ["iam:GetInstanceProfile"]
  }
  ## 클러스터 엔드포인트에 대해 정보를 가져올 수 있습니다
  statement {
    sid       = "AllowAPIServerEndpointDiscovery"
    resources = ["arn:${local.partition}:eks:${local.region}:${local.account_id}:cluster/${var.cluster_name}"]
    actions   = ["eks:DescribeCluster"]
  }
}

resource "aws_iam_policy" "controller" {
  name        = "karpenter-controller-policy-${var.cluster_name}"
  policy      = data.aws_iam_policy_document.karpenter_policy.json
}

## 신뢰 관계
data "aws_iam_policy_document" "controller_assume_role" {
  statement {
      actions = ["sts:AssumeRoleWithWebIdentity"]
      principals {
        type        = "Federated"
        identifiers = ["arn:aws:iam::${local.account_id}:oidc-provider/${var.irsa_oidc_provider_issuer}"]
      }
      condition {
        test = "StringEquals"
        variable = "${var.irsa_oidc_provider_issuer}:sub"
        values   = [for sa in var.irsa_namespace_service_accounts : "system:serviceaccount:${sa}"]
      }
      # https://aws.amazon.com/premiumsupport/knowledge-center/eks-troubleshoot-oidc-and-irsa/?nc1=h_ls
      condition {
        test = "StringEquals"
        variable = "${var.irsa_oidc_provider_issuer}:aud"
        values   = ["sts.amazonaws.com"]
    }
  }
}

## Role
resource "aws_iam_role" "controller" {
  name        = "karpenter-controller-Role-${var.cluster_name}"

  assume_role_policy    = data.aws_iam_policy_document.controller_assume_role.json
  force_detach_policies = true
}

## Role policy 할당
resource "aws_iam_role_policy_attachment" "controller" {
  role       = aws_iam_role.controller.name
  policy_arn = aws_iam_policy.controller.arn
}

################################################################################
# Node IAM Role
# 카펜터가 노드를 시작할때 사용하는 Instance Profile Role 입니다
################################################################################

locals {
  node_iam_role_name          = coalesce(var.node_iam_role_name, "Karpenter-Ndoe-${var.cluster_name}")
  node_iam_role_policy_prefix = "arn:${local.partition}:iam::aws:policy"

  ipv4_cni_policy = { for k, v in {
    AmazonEKS_CNI_Policy = "${local.node_iam_role_policy_prefix}/AmazonEKS_CNI_Policy"
  } : k => v }

}

data "aws_iam_policy_document" "node_assume_role" {
  statement {
    sid     = "EKSNodeAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node" {
  name        = local.node_iam_role_name
  assume_role_policy    = data.aws_iam_policy_document.node_assume_role.json   
  force_detach_policies = true

  # permissions_boundary  = var.node_iam_role_permissions_boundary
}

# Policies attached ref https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group
resource "aws_iam_role_policy_attachment" "node" {
  for_each = { for k, v in merge(
    {
      AmazonEKSWorkerNodePolicy          = "${local.node_iam_role_policy_prefix}/AmazonEKSWorkerNodePolicy"
      AmazonEC2ContainerRegistryReadOnly = "${local.node_iam_role_policy_prefix}/AmazonEC2ContainerRegistryReadOnly"
    },
    local.ipv4_cni_policy ) : k => v }

  policy_arn = each.value
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_additional" {
  for_each = { for k, v in var.node_iam_role_additional_policies : k => v }

  policy_arn = each.value
  role       = aws_iam_role.node.name
}

################################################################################
# SQS &  Evnet Bridge 
# 카펜터가 노드 Disruption 하기위한 이벤트와 큐 생성
################################################################################

## Spot instacne Service-Linked-Role
## https://docs.aws.amazon.com/cli/latest/reference/iam/create-service-linked-role.html
resource "aws_iam_service_linked_role" "spot_instance" {
  count = var.enabled_spot_linked_role ? 1 : 0
  aws_service_name = "spot.amazonaws.com"
}

################################################################################
# Node Termination Queue
################################################################################

locals {
  queue_name = coalesce(var.queue_name, "Karpenter-Node-Queue-${var.cluster_name}")
}

resource "aws_sqs_queue" "this" {
  name                              = local.queue_name
  message_retention_seconds         = 300
  # sqs_managed_sse_enabled           = var.queue_managed_sse_enabled ? var.queue_managed_sse_enabled : null
  # kms_master_key_id                 = var.queue_kms_master_key_id
  # kms_data_key_reuse_period_seconds = var.queue_kms_data_key_reuse_period_seconds
}

data "aws_iam_policy_document" "queue" {
  statement {
    sid       = "SqsWrite"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.this.arn]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "sqs.amazonaws.com",
      ]
    }
  }
  statement {
    sid    = "DenyHTTP"
    effect = "Deny"
    actions = [
      "sqs:*"
    ]
    resources = [aws_sqs_queue.this.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
    principals {
      type = "*"
      identifiers = [
        "*"
      ]
    }
  }
}

resource "aws_sqs_queue_policy" "this" {
  queue_url = aws_sqs_queue.this.url
  policy    = data.aws_iam_policy_document.queue.json
}

################################################################################
# Node Termination Event Rules
################################################################################

## 상태 종류 4가지의 대한 이벤트 metadata
locals {
  events = {
    health_event = {
      name        = "HealthEvent"
      description = "Karpenter interrupt - AWS health event"
      event_pattern = {
        source      = ["aws.health"]
        detail-type = ["AWS Health Event"]
      }
    }
    spot_interrupt = {
      name        = "SpotInterrupt"
      description = "Karpenter interrupt - EC2 spot instance interruption warning"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Spot Instance Interruption Warning"]
      }
    }
    instance_rebalance = {
      name        = "InstanceRebalance"
      description = "Karpenter interrupt - EC2 instance rebalance recommendation"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Instance Rebalance Recommendation"]
      }
    }
    instance_state_change = {
      name        = "InstanceStateChange"
      description = "Karpenter interrupt - EC2 instance state-change notification"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Instance State-change Notification"]
      }
    }
  }
}

resource "aws_cloudwatch_event_rule" "this" {
  for_each = { for k, v in local.events : k => v }

  name_prefix   = "${each.value.name}"
  description   = each.value.description
  event_pattern = jsonencode(each.value.event_pattern)

}

resource "aws_cloudwatch_event_target" "this" {
  for_each = { for k, v in local.events : k => v }

  rule      = aws_cloudwatch_event_rule.this[each.key].name
  target_id = "KarpenterInterruptionQueueTarget"
  arn       = aws_sqs_queue.this.arn
}