variable "eso_role_arn" {
  description = "eso role arn"
  type        = string
}

variable "vault_role_arn" {
  description = "vault kms role arn"
  type        = string
}

variable "efs_id" {
  description = "efs id"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable gitlab_runner_role_arn {
  description = "GitLab Runner IAM Role ARN"
  type        = string
}

variable "loadbalancer_role_arn" {
  description = "IAM Role ARN for AWS Load Balancer Controller"
  type        = string
}