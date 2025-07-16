variable "mount_path" {
  description = "Path where the Kubernetes auth method will be enabled"
  type        = string
  default     = "kubernetes"
}

variable "k8s_host" {
  description = "Kubernetes API server host"
  type        = string
}

variable "k8s_ca_cert" {
  description = "Base64 encoded CA cert for Kubernetes API"
  type        = string
}

variable "token_reviewer_jwt" {
  description = "JWT token for Vault to authenticate with Kubernetes"
  type        = string
  sensitive   = true
}

variable "roles" {
  description = "Map of role name to role config"
  type = map(object({
    bound_service_account_names      = list(string)
    bound_service_account_namespaces = list(string)
    policies                         = list(string)
    ttl                              = optional(string)
  }))
  default = {}
}