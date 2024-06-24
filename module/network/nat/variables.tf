variable "name" {
  description = "NAT Gateway 이름"
  type        = string
}

variable "subnet_id" {
  description = "NAT Gateway를 생성할 서브넷 ID"
  type        = string
}

variable "tags" {
  description = "생성될 리소스에 부여할 태그 목록"
  type        = map(string)
  default     = {}
}
