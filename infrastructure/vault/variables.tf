variable "vault_address" {
  description = "The address of the Vault server."
  type        = string
}
variable "vault_token" {
  description = "The token to authenticate with Vault."
  type        = string
  sensitive   = true
}
