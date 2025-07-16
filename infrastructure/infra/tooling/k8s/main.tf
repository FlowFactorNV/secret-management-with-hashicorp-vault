module "kubernetes_resources" {
    source = "../../modules/k8s"

    efs_id           = var.efs_id
    kustomize_path   = "clusters/tooling-cluster/"
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
    ESO_ROLE_ARN = var.eso_role_arn
    VAULT_ROLE_ARN = var.vault_role_arn
    GITLAB_RUNNER_ROLE_ARN = var.gitlab_runner_role_arn
    CLUSTER_NAME = var.cluster_name
    LOADBALANCER_ROLE_ARN = var.loadbalancer_role_arn
  }

  type = "Opaque"
}