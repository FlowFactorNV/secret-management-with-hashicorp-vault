data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_iam_policy_document" "vault_assume" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:vault:vault-kms"]
    }
  }
}

resource "aws_iam_role" "vault_irsa_role" {
  name               = "${var.cluster_name}-vault-irsa-role"
  assume_role_policy = data.aws_iam_policy_document.vault_assume.json
}

resource "aws_iam_role_policy" "vault_kms_policy" {
  name   = "${var.cluster_name}-vault-kms-policy"
  role   = aws_iam_role.vault_irsa_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey*"
        ]
        Resource = var.kms_key_arn
      }
    ]
  })
}

resource "aws_iam_instance_profile" "eks_efs_profile" {
  name = "${var.cluster_name}-EKS-EFS-InstanceProfile"
  role = aws_iam_role.efs_csi_driver.name
}

data "aws_iam_policy_document" "eso_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:eso:eso-irsa-sa"]
    }
  }
}

resource "aws_iam_role" "eso_irsa_role" {
  name               = "${var.cluster_name}-eso-irsa-role"
  assume_role_policy = data.aws_iam_policy_document.eso_assume_role.json
}

resource "aws_iam_role_policy" "eso_secretsmanager_policy" {
  name = "${var.cluster_name}-eso-secretsmanager-policy"
  role = aws_iam_role.eso_irsa_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = "arn:aws:secretsmanager:eu-west-1:${local.account_id}:secret:kms/*"
      }
    ]
  })
}

data "aws_iam_policy_document" "efs_csi_assume" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role" "efs_csi_driver" {
  name               = "${var.cluster_name}-efs-csi-controller-sa-role"
  assume_role_policy = data.aws_iam_policy_document.efs_csi_assume.json
}

resource "aws_iam_role_policy_attachment" "efs_csi_attach" {
  role       = aws_iam_role.efs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}

data "aws_iam_policy_document" "gitlab_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:gitlab:gitlab-runner"]
    }
  }
}
# Add role for Gitlab runner ecr access
resource "aws_iam_role" "gitlab_runner_irsa_role" {
  name = "${var.cluster_name}-gitlab-runner-irsa-role"

  assume_role_policy = data.aws_iam_policy_document.gitlab_assume_role.json
}

resource "aws_iam_role_policy_attachment" "gitlab_runner_ecr" {
  role       = aws_iam_role.gitlab_runner_irsa_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

data "aws_iam_policy_document" "loadbalancer_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "loadbalancer_irsa_role" {
  name               = "${var.cluster_name}-aws-load-balancer-controller-irsa-role"
  assume_role_policy = data.aws_iam_policy_document.loadbalancer_assume_role.json
}

resource "aws_iam_role_policy_attachment" "loadbalancer_attach" {
  role       = aws_iam_role.loadbalancer_irsa_role.name
  policy_arn = "arn:aws:iam::134128782576:policy/AWSLoadBalancerControllerIAMPolicy"
}
