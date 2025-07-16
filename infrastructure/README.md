# Secret Management

## Introduction
The goal of this project is to deploy a Kubernetes-based architecture in AWS, utilizing various technologies to deepen our knowledge and address potential customer inquiries. We focus on automating the entire deployment, so that it can ultimately be fully automated with Infrastructure as Code (IaC) and GitOps principles. Our infrastructure consists of two EKS clusters:
- **EKS - Application**: Contains the core application components such as the frontend, backend, database, and monitoring stack.
- **EKS - Tooling**: Supporting cluster for CI/CD and security, including GitLab Runner and HashiCorp Vault.

Below is a detailed overview of the key technologies and components within our architecture.

## 1. HashiCorp Vault
Vault plays a central role in secret management within our infrastructure. Our research focuses on:
- **High Availability (HA) Secret Manager**: Vault will be configured to manage secrets for both the application and tooling clusters.
- **Multi-Cluster Secret Management**: Vault must not only work within a single cluster but also be able to manage secrets across multiple clusters or external systems.
- **Key Rotation**: Automatically rotate keys and credentials for added security.
- **Short-Lived Secrets**: Generate and manage temporary credentials for secure access.
- **Application Integration**: Research how to implement key rotation and short-lived secrets within our applications.

## 2. Terraform (Infrastructure as Code - IaC)
Terraform is used to define and deploy the entire AWS infrastructure. This includes:
- **Network Infrastructure** (VPC, subnets, route tables, security groups)
- **EKS Clusters** (Tooling & Application)
- **Load Balancers & Ingress Controllers**
- **IAM Roles and Policies for secure access**

By using Terraform modules, we ensure that our infrastructure is reusable and scalable.

## 3. AWS Kubernetes (EKS)
EKS is AWS's managed Kubernetes solution. We have chosen to use this because we have previously worked with Google Cloud (GKE) and AWS offers a new learning experience.
Key aspects we are investigating within EKS:
- **Multi-cluster communication** (between Tooling and Application cluster)
- **Autoscaling and resource management**
- **EFS integration for shared storage**

## 4. Service Mesh (Microservices)
To ensure secure and efficient communication within the application cluster, we are implementing a service mesh. Possible technologies:
- **Istio**
- **Consul**

The service mesh provides:
- **Secure and encrypted communication** between services
- **Traffic management & observability**
- **Load balancing and retries**

## 5. Self-Hosted GitLab Runner
The GitLab Runner runs on the **EKS - Tooling** cluster and is responsible for executing CI/CD pipelines. This allows us to:
- **Automatically build, test, and deploy applications**
- **Deploy Infrastructure as Code (Terraform)**
- **Securely manage secrets** via Vault

The runner is managed and automated with **FluxCD**.

## 6. Helm
Helm is used to package and deploy Kubernetes applications. This helps with:
- **Automating installations and updates** of Kubernetes services
- **Providing version control and rollback options**
- **Ensuring consistent deployments**

## 7. FluxCD (GitOps)
FluxCD is used for GitOps-based deployments. This means that:
- **All infrastructure and application configuration** is managed in a Git repository
- **Kubernetes automatically syncs** with the desired state in Git
- **Changes are deployed in a controlled and secure manner**

FluxCD is used for:
- **Application deployments** in the application cluster
- **Management of HashiCorp Vault and GitLab Runner** in the tooling cluster

## Conclusion
With this project, we are realizing a fully automated and secure AWS-based Kubernetes architecture, focusing on secret management, CI/CD, service mesh, and GitOps. This not only enables us to learn new technologies but also to develop valuable insights and best practices applicable in an enterprise environment.