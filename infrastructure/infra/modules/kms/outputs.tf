output "kms_key_id" {
  description = "KMS key ID"
  value       = aws_kms_key.efs_key.key_id
}

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = aws_kms_key.efs_key.arn
}
