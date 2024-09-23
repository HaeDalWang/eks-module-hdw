## Spot instacne Service-Linked-Role
## https://docs.aws.amazon.com/cli/latest/reference/iam/create-service-linked-role.html
## Spot 권한 활성화 Spot을 한번이라도 사용하지 않았다면 사용
# resource "aws_iam_service_linked_role" "spot_instance" {
#   #count = var.enabled_spot_linked_role ? 1 : 0
#   aws_service_name = "spot.amazonaws.com"
# }