# Tooling Cluster GitOps

This repository contains the GitOps configuration for the **Tooling Kubernetes Cluster**, managed using [Flux](https://fluxcd.io/). 
It defines the state and deployment of core platform tools such as Vault, External Secrets Operator (ESO), and supporting infrastructure.

## Features

- **GitOps with Flux**: Fully automated deployment and reconciliation of cluster components.
- **Secret Management**: Integration with External Secrets Operator (ESO) to securely fetch secrets from AWS Secrets Manager or Vault.
- **Vault Integration**: Vault is deployed and configured to handle secrets securely within the cluster.
- **Service Account Automation**: Role bindings and service accounts are created dynamically using Flux substitutions.
- **Environment Separation**: Clean separation between infrastructure and application layers via structured repositories.

## Structure

```text
.
├── clusters/
│   └── tooling/         # Flux Kustomizations and cluster-specific overlays
├── tooling/      # ESO, Vault, and supporting components
└── README.md