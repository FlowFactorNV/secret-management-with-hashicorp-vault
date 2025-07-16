module "kubernetes_resources" {
    source = "../../modules/k8s"

    efs_id           = var.efs_id
    kustomize_path   = "clusters/app-cluster/"
}

resource "kubernetes_namespace" "flux_system" {
  metadata {
    name = "flux-system"
    labels           = {
      "app.kubernetes.io/instance" = "flux-system"
      "app.kubernetes.io/part-of"  = "flux"
      "app.kubernetes.io/version"  = "v2.5.1"
    }
  }
}

resource "kubernetes_secret" "bootstrap-secrets" {
  metadata {
    name      = "bootstrap-secrets"
    namespace = "flux-system"
  }

  data = {
    CLUSTER_NAME = var.cluster_name
    IMAGE_REFLECTOR_ROLE_ARN = var.image_reflector_role_arn
    LOADBALANCER_ROLE_ARN = var.loadbalancer_role_arn
  }

  type = "Opaque"
}