# Secret Management with HashiCorp Vault

A production-ready implementation of HashiCorp Vault on Kubernetes with automated GitOps deployment.

## What's in this repo?

This repository contains a complete setup for running HashiCorp Vault in a secure, scalable way on AWS EKS:

- **2 separate EKS clusters**: One for applications, one for tooling (Vault, CI/CD, GitLab Runner)
- **Infrastructure as Code**: Complete AWS infrastructure using Terraform modules
- **GitOps automation**: FluxCD manages all Kubernetes deployments
- **Zero-trust security**: Service mesh with Istio, mTLS enforcement, and explicit authorization policies
- **Dynamic secrets**: Automatic database credential rotation with configurable TTL
- **Complete documentation**: 140+ pages covering architecture decisions, implementation details, and lessons learned

## Prerequisites

As documented in section 10.1:
- AWS CLI configured with appropriate permissions
- Terraform (≥ version 1.4)
- kubectl
- Flux CLI
- Access to AWS account with permissions to create EKS clusters, VPCs, IAM roles, Load Balancers and VPNs
- Git repository with GitOps configuration

## Deployment Steps

Follow the installation guide in section 10:

### 1. Clone the infrastructure repository
```
git clone [your-repo-url]
cd /infra
```

#### 2. Initialize Terraform
```
terraform init
terraform plan
terraform apply
```

#### 3. After infrastructure is created, uncomment modules in main.tf for:

- Kubernetes modules
- Flux bootstrap
- VPN configuration

#### 4. Run Terraform again
```
terraform apply
```

### Accessing Vault

As documented in section 7, Vault is only accessible internally:
Generate VPN config: cd infrastructure/vpn && ./generate-config.sh
Connect to VPN: sudo openvpn --config client-config.ovpn
Access Vault at https://vault.tooling.internal:8200

Repository Structure

├── app-gitops/        # Application configurations (managed by FluxCD)
├── docs/              # Full documentation including system dossier
├── infrastructure/    # Terraform modules and cluster configurations
└── tooling-gitops/    # Tooling configurations (Vault, GitLab Runner, ESO)

## Troubleshooting

### Vault Bootstrap Issues (Section 10.5)

If Vault bootstrap crashes during first synchronization:

```
kubectl delete kustomization vault-bootstrap -n flux-system
kubectl delete secret vault-bootstrap-secret -n flux-system
flux reconcile kustomization vault-bootstrap --with-source
```

### GitLab Runner Setup (Section 10.6)

Add runner registration token to Vault:

```
vault kv put kv/gitlab/runner registrationToken=<your_token>
```

## Documentation

For complete details including architecture decisions and implementation notes:

📖 [Full Documentation](docs/en.md) (English)
📖 [Volledige Documentatie](docs/nl.md) (Nederlands)

## Architecture Highlights

- Multi-cluster setup for separation of concerns 
- HashiCorp Vault with Kubernetes auth method 
- Istio service mesh with zero-trust policies 
- GitLab Runner with Podman for secure CI/CD 
- Internal NLB + Route 53 for secure Vault access

## Disclaimer

📌 Test before deploying. Adjust for your needs. And if you need help? You know where to find us.
