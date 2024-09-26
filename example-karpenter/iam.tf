## Spot instacne Service-Linked-Role
## https://docs.aws.amazon.com/cli/latest/reference/iam/create-service-linked-role.html
## Spot 권한 활성화, Spot을 한번이라도 사용하지 않았다면 사용
## 테라폼 보다는 aws cli와 같이 aws 계정에 기준에서 활성/비활성 관리를 추천
# resource "aws_iam_service_linked_role" "spot_instance" {
#   #count = var.enabled_spot_linked_role ? 1 : 0
#   aws_service_name = "spot.amazonaws.com"
# }
