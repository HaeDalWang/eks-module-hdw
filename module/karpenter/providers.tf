terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.55.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.14.0"
    }
  }
}