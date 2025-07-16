output "root_cert" {
  value     = tls_self_signed_cert.root.cert_pem
  sensitive = true
}

output "root_key" {
  value     = tls_private_key.root.private_key_pem
  sensitive = true
}
