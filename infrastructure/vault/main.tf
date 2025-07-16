resource "vault_policy" "catalog" {
  name   = "catalog"
  policy = file("${path.module}/policies/catalog.hcl")
}

module "db_engine" {
  source = "./modules/secrets/database"

  path = "database/"
  plugin_name = "postgresql-database-plugin"
  allowed_roles = ["catalog"]
}


module "auth_kubernetes" {
  source = "./modules/auth/k8s"

  mount_path         = "kubernetes"
  k8s_host           = "https://kubernetes.default.svc"
  k8s_ca_cert        = filebase64("/var/run/secrets/kubernetes.io/serviceaccount/ca.crt")
  token_reviewer_jwt = file("/var/run/secrets/kubernetes.io/serviceaccount/token")
}
