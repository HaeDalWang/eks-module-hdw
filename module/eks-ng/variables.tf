variable "name" {
  description = "노드그룹 이름"
  type        = string
}

variable "cluster_name" {
  description = "노드그룹이 생성될 EKS 클러스터 이름"
  type        = string
}

variable "cluster_version" {
  description = "EKS 클러스터 버전"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "노드그룹을 통해서 생성된 노드들이 위치할 서브넷 목록"
  type        = list(string)
}

variable "instance_types" {
  description = "노드그룹에서 사용할 인스턴스 종류 목록"
  type        = list(string)
}

variable "min_size" {
  description = "노드그룹의 최소 노드 갯수"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "노드그룹의 최대 노드 갯수"
  type        = number
  default     = 10
}

variable "user_data" {
  description = "노드가 초기에 생성될때 실행할 스크립트"
  type        = string
  default     = ""
}

variable "tags" {
  description = "태그 목록"
  type        = map(string)
  default     = {}
}