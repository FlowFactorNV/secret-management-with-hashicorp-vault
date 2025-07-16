output "efs_role_arn" {
  description = "IAM Role ARN for EFS CSI Driver"
  value       = aws_iam_role.efs_csi_driver.arn
}

output "efs_instance_profile" {
  description = "IAM Instance Profile name for EKS worker nodes"
  value       = aws_iam_instance_profile.eks_efs_profile.name
}

output image_reflector_role_arn {
  description = "ARN of the image reflector role"
  value       = aws_iam_role.image_reflector_role.arn
}

output "loadbalancer_role_arn" {
  description = "IAM Role ARN for AWS Load Balancer Controller"
  value       = aws_iam_role.loadbalancer_irsa_role.arn
}