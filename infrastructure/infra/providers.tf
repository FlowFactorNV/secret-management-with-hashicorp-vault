terraform {
  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
    region = var.zone
}


provider "kubernetes" {
    alias = "tooling"
    host                   = module.tooling-eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.tooling-eks.cluster_ca)
    token                  = module.tooling-eks.eks_token
}

provider "flux" {
    alias = "tooling"
    kubernetes = {
    host                   = module.tooling-eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.tooling-eks.cluster_ca)
    token                  = module.tooling-eks.eks_token
    }

    git = {
      url = "ssh://${var.git_repo_ssh_tooling}"
      branch            = var.git_branch_tooling

      ssh = {
        username          = "git"
        private_key       = file(var.flux_git_ssh_private_key_path)
      }
    }
}

provider "kubernetes" {
    alias = "app"
    host                   = module.app-eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.app-eks.cluster_ca)
    token                  = module.app-eks.eks_token
}

provider "flux" {
    alias = "app"
    kubernetes = {
    host                   = module.app-eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.app-eks.cluster_ca)
    token                  = module.app-eks.eks_token
    }

    git = {
      url = "ssh://${var.git_repo_ssh_app}"
      branch            = var.git_branch_app

      ssh = {
        username          = "git"
        private_key       = file(var.flux_git_ssh_private_key_path)
      }
    }
}