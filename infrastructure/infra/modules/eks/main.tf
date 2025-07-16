module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.32"

  enable_irsa                    = true
  bootstrap_self_managed_addons = true
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    aws-efs-csi-driver     = {
      service_account_role_arn = var.efs_irsa_role_arn
    }
  }

  cluster_endpoint_public_access            = true
  enable_cluster_creator_admin_permissions  = true

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnets
  control_plane_subnet_ids = var.public_subnets

  eks_managed_node_group_defaults = {
    instance_types         = var.default_instance_types
    vpc_security_group_ids = [var.efs_security_group_id]
    iam_instance_profile   = var.iam_instance_profile
  }

  eks_managed_node_groups = {
    default = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m6i.large"]

      min_size     = 3
      max_size     = 10
      desired_size = 3
    }
  }

  tags = var.tags
}

data "aws_eks_cluster_auth" "this" { name = module.eks.cluster_name}
