output "root_cert" {
  value     = module.vpn.root_cert
  sensitive = true
}

output "root_key" {
  value     = module.vpn.root_key
  sensitive = true
}
