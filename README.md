# Secret Management with HashiCorp Vault

June 16, 2025

## Executive summary

The project focused on deploying two separate EKS clusters: one for an application environment and
one for supporting tooling such as CI/CD and secret management. Central to this project were
technologies such as HashiCorp Vault for secure secret management, Terraform for Infrastructure as
Code, Helm for Kubernetes application management, and FluxCD for GitOps-based automation.

Our tasks included the full automation of the infrastructure, setting up secure multi-cluster
communication, integrating a service mesh for microservices communication, and building CI/CD
pipelines with a self-hosted GitLab Runner. We also developed an approach for secure and efficient
secret management, including key rotation and the use of short-lived credentials.

You can read the full documentation in [Dutch](/docs/nl.md) (original) or in [English](/docs/en.md) (AI-translated, proofread).
