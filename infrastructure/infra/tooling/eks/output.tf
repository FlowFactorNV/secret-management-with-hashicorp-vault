output "eso_role_arn" {
  description = "Eso role arn"
  value       = module.iam.eso_role_arn
}

output "vault_role_arn" {
  description = "Eso role arn"
  value       = module.iam.vault_role_arn
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_ca" {
  value = module.eks.cluster_certificate_authority_data
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "eks_token" {
  value = module.eks.eks_token
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "efs_id" {
  description = "EFS ID"
  value       = module.efs.id
}

output gitlab_runner_role_arn {
  description = "GitLab Runner IAM Role ARN"
  value       = module.iam.gitlab_runner_role_arn
}

output "loadbalancer_role_arn" {
  description = "IAM Role ARN for AWS Load Balancer Controller"
  value       = module.iam.loadbalancer_role_arn
} 