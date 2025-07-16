module "iam" {
  source             = "../iam"
  cluster_name       = var.cluster_name
  oidc_provider_arn  = module.eks.oidc_provider_arn
  oidc_issuer_url    = module.eks.cluster_oidc_issuer_url
}

module "kms" {
  source                  = "../../modules/kms"
  cluster_name                  = var.cluster_name
  environment             = var.tags["Environment"]
  deletion_window_in_days = 20
}

module "efs" {
  source                      = "../../modules/efs"
  cluster_name                      = var.cluster_name
  vpc_id                      = var.vpc_id
  private_subnets             = var.private_subnets
  azs_map                     = var.azs_map
  private_subnets_cidr_blocks = var.private_subnets_cidr_blocks
  efs_irsa_role_arn           = module.iam.efs_role_arn
  kms_key_arn                 = module.kms.kms_key_arn
  tags                        = var.tags
}

module "eks" {
  source                  = "../../modules/eks"
  cluster_name            = var.cluster_name
  vpc_id                  = var.vpc_id
  private_subnets         = var.private_subnets
  public_subnets          = var.public_subnets
  efs_irsa_role_arn       = module.iam.efs_role_arn
  iam_instance_profile    = module.iam.efs_instance_profile
  efs_security_group_id   = module.efs.security_group_id
  tags                    = var.tags
}

resource "aws_security_group_rule" "node_ingress_15017_from_cluster" {
  type                     = "ingress"
  from_port                = 15017
  to_port                  = 15017
  protocol                 = "tcp"
  security_group_id        = module.eks.node_security_group_id
  source_security_group_id = module.eks.cluster_security_group_id
  description              = "Allow 15017 from cluster SG to node SG"
}