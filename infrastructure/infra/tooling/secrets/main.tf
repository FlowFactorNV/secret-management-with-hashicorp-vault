resource "aws_secretsmanager_secret" "kms_key_id" {
  name = "kms/kms_key_id_cis"
}

resource "aws_secretsmanager_secret_version" "kms_key_id_value" {
  secret_id     = aws_secretsmanager_secret.kms_key_id.id
  secret_string = jsonencode({
    kms_key_id = var.kms_key_id
  })
}
