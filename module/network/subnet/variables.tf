variable "prefix" {
  description = "서브넷 이름에 추가할 접두사"
  type        = string
}

variable "suffix" {
  description = "서브넷 이름에 추가할 접미사"
  type        = string
}

variable "vpc_id" {
  description = "서브넷을 생성할 VPC ID"
  type        = string
}

variable "cidr" {
  description = "생성할 서브넷들의 CIDR 목록"
  type        = list(string)
}

variable "azs" {
  description = "CIDR 목록에 1:1 매칭 되는 가용영역 목록"
  type        = list(string)
}

variable "type" {
  type        = string
  description = "서브넷 종류 - public 또는 private"

  validation {
    condition     = contains(["public", "private"], var.type)
    error_message = "Valid values for var: type are (public, private)."
  }
}

variable "tags" {
  description = "생성될 리소스에 부여할 태그 목록"
  type        = map(string)
  default     = {}
}

variable "gateway_id" {
  description = "인터넷 게이트웨이 ID - 서브넷 종류가 public 일때 명시"
  type        = string
  default     = ""
}

variable "nat_gateway_id" {
  description = "NAT 게이트웨이 ID - 서브넷 종류가 private 일때 명시"
  type        = string
  default     = ""
}