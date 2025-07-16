variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "environment" {
  description = "Environment tag value"
  type        = string
  default     = "dev"
}

variable "deletion_window_in_days" {
  description = "KMS deletion window"
  type        = number
  default     = 20
}
