resource "kubernetes_manifest" "efs_storage_class" {
  manifest = {
    apiVersion = "storage.k8s.io/v1"
    kind       = "StorageClass"
    metadata = {
      name        = "efs-sc"
      annotations = {
        "storageclass.kubernetes.io/is-default-class" = "true"
      }
    }
    provisioner = "efs.csi.aws.com"
    parameters = {
      provisioningMode = "efs-ap"
      fileSystemId     = var.efs_id
      directoryPerms   = "700"
    }
    mountOptions = [
      "nfsvers=4.1"
    ]
    reclaimPolicy     = "Delete"
    volumeBindingMode = "Immediate"
  }
}


resource "flux_bootstrap_git" "flux" {
  path      = var.kustomize_path
  namespace = "flux-system"
  version   = "v2.5.1"

  components       = ["source-controller", "kustomize-controller", "helm-controller"] #, "notification-controller"]"
  components_extra = ["image-reflector-controller", "image-automation-controller"]
}

