# Enable the Kubernetes auth method
resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = var.mount_path
}

# Configure Vault to talk to Kubernetes
resource "vault_kubernetes_auth_backend_config" "k8s" {
  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host    = var.k8s_host
  kubernetes_ca_cert = var.k8s_ca_cert
  token_reviewer_jwt = var.token_reviewer_jwt
}

# Define roles that map Kubernetes service accounts to Vault policies
resource "vault_kubernetes_auth_backend_role" "roles" {
  for_each = var.roles

  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = each.key
  bound_service_account_names      = each.value.bound_service_account_names
  bound_service_account_namespaces = each.value.bound_service_account_namespaces
  policies                         = each.value.policies
  ttl                              = lookup(each.value, "ttl", null)
}