resource "aws_kms_key" "efs_key" {
  description             = "KMS key for EFS encryption"
  deletion_window_in_days = var.deletion_window_in_days

  tags = {
    Name        = "${var.cluster_name} EFS Encryption Key"
    Environment = var.environment
    Terraform   = "true"
  }
}
