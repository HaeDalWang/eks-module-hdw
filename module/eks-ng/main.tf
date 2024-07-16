# 노드그룹을 통해서 생성되는 노드에 부여할 IAM 역할
resource "aws_iam_role" "this" {
  name = "${var.cluster_name}-${var.name}-eks-nodegroup-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# EKS 노드에 부여할 IAM 정책 목록
resource "aws_iam_role_policy_attachment" "this-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "this-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "this-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "this-AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.this.name
}

# 노드그룹에 적용할 EC2 시작 템플릿
resource "aws_launch_template" "this" {
  name = "${var.cluster_name}-${var.name}"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type = "gp3"
      volume_size = 20
    }
  }

  dynamic "tag_specifications" {
    for_each = toset(["instance", "volume"])
    content {
      resource_type = tag_specifications.key
      tags = {
        Name = "${var.cluster_name}-${var.name}"
      } 
    }
  }

  user_data = base64encode(var.user_data)
}

# EKS 노드 그룹
resource "aws_eks_node_group" "this" {
  cluster_name    = var.cluster_name
  version         = var.cluster_version
  node_group_name = var.name
  node_role_arn   = aws_iam_role.this.arn
  subnet_ids      = var.subnet_ids
  instance_types  = var.instance_types

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  scaling_config {
    desired_size = var.min_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  /* 오토스케일링 그룹의 원하는 갯수(Desired Capacity)는 유동적이므로 테라폼코드에
  명시된 값과 다르더라도 무시 */
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  update_config {
    max_unavailable = 1
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.this-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.this-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.this-AmazonEKS_CNI_Policy
  ]

  timeouts {
    create = "10m"
  }
}