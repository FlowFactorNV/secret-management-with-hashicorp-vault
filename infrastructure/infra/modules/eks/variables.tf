variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnets" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "efs_irsa_role_arn" {
  description = "IAM role ARN for EFS CSI driver"
  type        = string
}

variable "efs_security_group_id" {
  description = "Security group ID for EFS"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile for EKS worker nodes"
  type        = string
}

variable "default_instance_types" {
  description = "Default instance types for managed node groups"
  type        = list(string)
  default     = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
}
