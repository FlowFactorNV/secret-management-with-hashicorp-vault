variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "vpc-cis"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "client_cidr_block" {
  description = "CIDR block for the VPN"
  type        = string
  default     = "10.100.0.0/22"
}

variable "tooling_cluster_name" {
  description = "tooling EKS Cluster name"
  type        = string
  default     = "cis-tooling"
}

variable "app_cluster_name" {
  description = "app EKS Cluster name"
  type        = string
  default     = "cis-app"
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"] #, "eu-west-1c"]
}

variable "zone" {
    description = "Zone for the provider"
    type        = string
    default     = "eu-west-1"
}

variable "private_subnets" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]#, "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]#, "10.0.103.0/24"]
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "quinten-dev"
  }
}

variable "flux_git_ssh_private_key_path" {
  description = "Path to the private SSH key for Flux Git"
  type        = string
  default     = "~/.ssh/gitlab"
}

variable "git_repo_ssh_tooling" {
  description = "SSH URL of the tooling GitOps repository"
  type        = string
  default     = ""
}

variable "git_branch_tooling" {
  description = "Branch of the tooling GitOps repository"
  type        = string
  default     = "main"
}

variable "git_repo_ssh_app" {
  description = "SSH URL of the app GitOps repository"
  type        = string
  default     = ""
}

variable "git_branch_app" {
  description = "Branch of the app GitOps repository"
  type        = string
  default     = "main"
}

variable "ingress_cidr_blocks" {
  description = "CIDR blocks for access HTTP/HTTPS"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "target_group_port" {
  description = "Port for the target group"
  type        = number
  default     = 80
}

variable "target_group_protocol" {
  description = "Protocol for the target group"
  type        = string
  default     = "HTTP"
}
