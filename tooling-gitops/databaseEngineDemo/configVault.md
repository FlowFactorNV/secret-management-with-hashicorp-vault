1. vault secrets enable database
2. 
vault write database/config/db-demo \
  plugin_name=postgresql-database-plugin \
  allowed_roles="readonly" \
  connection_url="postgresql://{{username}}:{{password}}@postgres-demo.default.svc.cluster.local:5432/demo?sslmode=disable" \
  username="vaultadmin" \
  password="vaultadminpassword"

vault write database/roles/readonly \
  db_name=db-demo \
  creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT CONNECT ON DATABASE demo TO \"{{name}}\";" \
  default_ttl="30s" \
  max_ttl="1m"

vault policy write db-readonly db-readonly.hcl
# db-readonly.hcl 
path "database/creds/readonly" {
  capabilities = ["read"]
}

vault write auth/kubernetes/role/db-engine-demo \
    bound_service_account_names="db-engine-demo-sa" \
    bound_service_account_namespaces="default" \
    policies="db-readonly" \
    ttl="1h"

