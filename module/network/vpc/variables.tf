variable "name" {
  description = "VPC 이름"
  type        = string
}

variable "cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "tags" {
  description = "생성될 리소스에 부여할 태그 목록"
  type        = map(string)
  default     = {}
}
