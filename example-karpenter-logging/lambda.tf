# 람다 실행 Role
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# Lambda 실행 역할 정책 문서 (ECR 및 ENI 권한 추가)
data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect = "Allow"

    # ECR 접근 권한
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:DescribeImages"
    ]

    resources = [
      "arn:aws:ecr:ap-northeast-2:863422182520:repository/flask-echo" # ECR 리포지토리 ARN
    ]
  }

  statement {
    effect = "Allow"

    # ECR 인증 토큰 가져오기
    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"] # ECR 인증 토큰은 리소스 제약 없음
  }

  statement {
    effect = "Allow"

    # ENI 관련 권한
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]

    resources = ["*"] # ENI는 특정 리소스 ARN이 아닌 전체 권한 필요
  }
}

# Lambda 실행 역할에 정책 추가
resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.iam_for_lambda.name
  policy = data.aws_iam_policy_document.lambda_policy.json
}

# Lambda용 보안 그룹 생성 (모든 트래픽 허용)
resource "aws_security_group" "lambda_test_sg" {
  name        = "lambda_security_test_group"
  description = "Security group for Lambda with open traffic"
  vpc_id      = module.vpc.vpc_id

  # 인바운드 트래픽: 모든 트래픽 허용
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # 모든 프로토콜 허용
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 아웃바운드 트래픽: 모든 트래픽 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # 모든 프로토콜 허용
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 람다 테스트 함수
resource "aws_lambda_function" "test_lambda" {
  image_uri     = "863422182520.dkr.ecr.ap-northeast-2.amazonaws.com/flask-echo:latest"
  function_name = "test_function"
  role          = aws_iam_role.iam_for_lambda.arn
  package_type  = "Image"

  # runtime과 handler는 image_uri를 사용할 때 불필요하므로 제거
  # runtime       = "python3.12"
  # handler       = "test_function.echo"

  vpc_config {
    subnet_ids         = module.vpc.private_subnet_ids
    security_group_ids = [aws_security_group.lambda_test_sg.id]
  }
}

