terraform {
  required_providers {
    flux = {
      source  = "fluxcd/flux"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}
