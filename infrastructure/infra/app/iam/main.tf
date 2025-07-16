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

resource "aws_iam_instance_profile" "eks_efs_profile" {
  name = "${var.cluster_name}-EKS-EFS-InstanceProfile"
  role = aws_iam_role.efs_csi_driver.name
}

data "aws_iam_policy_document" "image_reflector_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:flux-system:image-reflector-controller"]
    }
  }
}

resource "aws_iam_role" "image_reflector_role" {
  name               = "${var.cluster_name}-flux-image-reflector-role"
  assume_role_policy = data.aws_iam_policy_document.image_reflector_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.image_reflector_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
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
