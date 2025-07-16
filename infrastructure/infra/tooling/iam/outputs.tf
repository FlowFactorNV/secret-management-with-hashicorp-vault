output "efs_role_arn" {
  description = "IAM Role ARN for EFS CSI Driver"
  value       = aws_iam_role.efs_csi_driver.arn
}

output "efs_instance_profile" {
  description = "IAM Instance Profile name for EKS worker nodes"
  value       = aws_iam_instance_profile.eks_efs_profile.name
}

output "vault_role_arn" {
  description = "IAM Role ARN for Vault IRSA"
  value       = aws_iam_role.vault_irsa_role.arn
}

output "eso_role_arn" {
  description = "IAM Role ARN for ESO IRSA"
  value       = aws_iam_role.eso_irsa_role.arn
}

output "gitlab_runner_role_arn" {
  description = "IAM Role ARN for GitLab Runner IRSA"
  value       = aws_iam_role.gitlab_runner_irsa_role.arn
}

output "loadbalancer_role_arn" {
  description = "IAM Role ARN for AWS Load Balancer Controller"
  value       = aws_iam_role.loadbalancer_irsa_role.arn
}