output "id" {
  description = "EFS file system ID"
  value       = module.efs.id
}

output "security_group_id" {
  description = "Security group for EFS"
  value       = module.efs.security_group_id
}
