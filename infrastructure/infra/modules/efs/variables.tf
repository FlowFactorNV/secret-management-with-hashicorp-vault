variable "cluster_name" {
  description = "prefix name"
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

variable "private_subnets_cidr_blocks" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "efs_irsa_role_arn" {
  description = "IAM Role ARN for EFS CSI driver"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for EFS encryption"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}

variable "azs_map" {
  description = "Map of availability zones to private subnets"
  type        = map(object({
    subnet_id = string
  }))
}
