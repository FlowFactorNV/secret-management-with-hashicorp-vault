variable "efs_id" {
  description = "efs id"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "image_reflector_role_arn" {
  description = "ARN of the image reflector role"
  type        = string
}

variable "loadbalancer_role_arn" {
  description = "IAM Role ARN for AWS Load Balancer Controller"
  type        = string
}