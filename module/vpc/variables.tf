################################################################################
# VPC
################################################################################
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

################################################################################
# Subnets
################################################################################
variable "azs" {
  description = "서브넷의 가용영역"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "생성할 퍼블릭 서브넷의 CIDR"
  type        = list(string)
  default     = []
}

variable "public_subnet_tags" {
  description = "퍼블릭 서브넷에 추가할 Tag"
  type        = map(string)
  default     = {}
}


variable "private_subnets" {
  description = "생성할 프라이빗 서브넷의 CIDR"
  type        = list(string)
  default     = []
}

variable "private_subnet_tags" {
  description = "프라이빗 서브넷에 추가할 Tag"
  type        = map(string)
  default     = {}
}

variable "nat_gateway_enabled" {
  description = "NAT Gateway 활성화 유무"
  type = bool
  default = false
}
