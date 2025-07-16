module "vpc" {
  source = "./modules/vpc"

  vpc_name        = var.vpc_name
  vpc_cidr        = var.vpc_cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  client_cidr_block = var.client_cidr_block
  tags            = var.tags
}

locals {
  az_to_subnet_map = {
    for idx, az in var.azs :
    az => {
      subnet_id = module.vpc.private_subnets[idx]
    }
  }
}

module "tooling-eks" {
    source = "./tooling/eks"
    
    cluster_name            = var.tooling_cluster_name
    vpc_id                  = module.vpc.vpc_id
    tags                   = var.tags
    private_subnets         = module.vpc.private_subnets
    azs_map             = local.az_to_subnet_map
    private_subnets_cidr_blocks = module.vpc.private_subnets_cidr_blocks
    public_subnets          = module.vpc.public_subnets
}

module "tooling-k8s" {
    source = "./tooling/k8s"
    cluster_name      = var.tooling_cluster_name
    efs_id           = module.tooling-eks.efs_id
    eso_role_arn     = module.tooling-eks.eso_role_arn
    vault_role_arn   = module.tooling-eks.vault_role_arn
    gitlab_runner_role_arn = module.tooling-eks.gitlab_runner_role_arn
    loadbalancer_role_arn = module.tooling-eks.loadbalancer_role_arn
    depends_on       = [module.tooling-eks]
    providers = {
        kubernetes = kubernetes.tooling
        flux = flux.tooling
    }
}

module "app-eks" {
    source = "./app/eks"
    
    cluster_name            = var.app_cluster_name
    vpc_id                  = module.vpc.vpc_id
    tags                    = var.tags
    private_subnets         = module.vpc.private_subnets
    azs_map             = local.az_to_subnet_map
    private_subnets_cidr_blocks = module.vpc.private_subnets_cidr_blocks
    public_subnets          = module.vpc.public_subnets
}

module "app-k8s" {
    source = "./app/k8s"
    efs_id           = module.app-eks.efs_id
    cluster_name      = var.app_cluster_name
    image_reflector_role_arn = module.app-eks.image_reflector_role_arn
    loadbalancer_role_arn = module.app-eks.loadbalancer_role_arn
    #kustomize_path   = "clusters/app-cluster/"
    depends_on       = [module.app-eks]
    providers = {
        kubernetes = kubernetes.app
        flux = flux.app
    }
}

module "vpn" {
  depends_on = [module.vpc]
  source = "./modules/vpn"

  client_cidr_block   = var.client_cidr_block
  subnet_ids           = module.vpc.private_subnets
  vpc_cidr_block      = var.vpc_cidr
}
