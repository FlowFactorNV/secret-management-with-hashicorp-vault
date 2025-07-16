module "efs" {
  source = "terraform-aws-modules/efs/aws"

  name           = "${var.cluster_name}-efs"
  creation_token = "${var.cluster_name}-efs-token"
  encrypted      = true
  kms_key_arn    = var.kms_key_arn

  lifecycle_policy = {
    transition_to_ia = "AFTER_30_DAYS"
  }

  attach_policy                       = true
  bypass_policy_lockout_safety_check = false
  policy_statements = [
    {
      sid     = "AllowEKSAccess"
      actions = [
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientRead",
        "elasticfilesystem:ClientWrite"
      ]
      principals = [
        {
          type        = "AWS"
          identifiers = [var.efs_irsa_role_arn]
        }
      ]
    }
  ]

  mount_targets = var.azs_map

  security_group_description = "EFS security group"
  security_group_vpc_id      = var.vpc_id
  security_group_rules = {
    vpc = {
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = var.private_subnets_cidr_blocks
    }
  }

  access_points = {
    default = {
      root_directory = {
        path = "/efs-data"
        creation_info = {
          owner_gid   = 1001
          owner_uid   = 1001
          permissions = "755"
        }
      }
    }
  }

  enable_backup_policy = true

  tags = var.tags
}