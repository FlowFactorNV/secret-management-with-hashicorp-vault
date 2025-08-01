# Secret Management with HashiCorp Vault


This project implements a production-ready HashiCorp Vault setup within a multi-cluster Kubernetes environment on AWS. The architecture consists of two separate EKS clusters: one for applications and one for supporting tooling such as CI/CD and secret management. Core technologies include HashiCorp Vault for secure secret management, Terraform for Infrastructure as Code, Helm for Kubernetes application management, and FluxCD for GitOps-based automation. The implementation encompasses full infrastructure automation, secure multi-cluster communication, service mesh integration for microservices communication, and CI/CD pipelines with a self-hosted GitLab Runner. The system implements a zero-trust security model with dynamic secret management, including automatic key rotation and short-lived credentials. This document provides a complete overview of the architecture, implementation details, and practical deployment instructions.

# Table of Contents

- [1. Introduction](#1-introduction)
- [2. Presentation of the company](#2-presentation-of-the-company)
- [3. Description of the assignment](#3-description-of-the-assignment)
- [4. System Architecture](#4-system-architecture)
- [5. AWS Infrastructure](#5-aws-infrastructure)
- [6. Application cluster (EKS-application)](#6-application-cluster-eks-application)
- [7. Tooling cluster (EKS-tooling)](#7-tooling-cluster-eks-tooling)
- [8. In-depth look at the tools used](#8-in-depth-look-at-the-tools-used)
  * [8.1 Terraform (Infrastructure as Code)](#81-terraform-infrastructure-as-code)
    + [8.1.1 Terraform - What is it?](#811-terraform-what-is-it)
    + [8.1.2 Terraform - How does it work?](#812-terraform---how-does-it-work-)
    + [8.1.3 Terraform - Why was it chosen?](#813-terraform---why-was-it-chosen-)
    + [8.1.4 Terraform - How was it implemented?](#814-terraform---how-was-it-implemented-)
    + [8.1.5 Terraform - Advantages](#815-terraform---advantages)
    + [8.1.6 Terraform - Disadvantages](#816-terraform---disadvantages)
  * [8.2 Helm](#82-helm)
    + [8.2.1 Helm - What is it?](#821-helm---what-is-it-)
    + [8.2.2 Helm - Components of Helm](#822-helm---components-of-helm)
    + [8.2.3 Helm - How does it work?](#823-helm---how-does-it-work-)
    + [8.2.4 Helm - Why was it chosen?](#824-helm---why-was-it-chosen-)
    + [8.2.5 Helm - How was it implemented?](#825-helm---how-was-it-implemented-)
    + [8.2.6 Helm - Advantages](#826-helm---advantages)
    + [8.2.7 Helm - Disadvantages](#827-helm---disadvantages)
  * [8.3 GitOps (FluxCD)](#83-gitops--fluxcd-)
    + [8.3.1 FluxCD - What is it?](#831-fluxcd---what-is-it-)
    + [8.3.2 FluxCD - Components of FluxCD](#832-fluxcd---components-of-fluxcd)
    + [8.3.3 FluxCD - How does it work?](#833-fluxcd---how-does-it-work-)
    + [8.3.4 FluxCD - Why was it chosen?](#834-fluxcd---why-was-it-chosen-)
    + [8.3.5 FluxCD - How was it implemented?](#835-fluxcd---how-was-it-implemented-)
    + [8.3.6 FluxCD - Advantages](#836-fluxcd---advantages)
    + [8.3.7 FluxCD - Disadvantages](#837-fluxcd---disadvantages)
  * [8.4 - Self-hosted GitLab runner](#84---self-hosted-gitlab-runner)
    + [8.4.1 GitLab runner - What is it?](#841-gitlab-runner---what-is-it-)
    + [8.4.2 GitLab runner - Components of Gitlab Runner](#842-gitlab-runner---components-of-gitlab-runner)
    + [8.4.3 GitLab runner - How does it work?](#843-gitlab-runner---how-does-it-work-)
    + [8.4.4 GitLab runner - Why was it chosen?](#844-gitlab-runner---why-was-it-chosen-)
    + [8.4.5 GitLab runner - How was it implemented?](#845-gitlab-runner---how-was-it-implemented-)
    + [8.4.6 GitLab runner - Alternatives](#846-gitlab-runner---alternatives)
    + [8.4.7 GitLab runner - Advantages](#847-gitlab-runner---advantages)
    + [8.4.8 GitLab runner - Disadvantages](#848-gitlab-runner---disadvantages)
  * [8.5 Service Mesh (Istio)](#85-service-mesh--istio-)
    + [8.5.1 Istio - What is it?](#851-istio---what-is-it-)
    + [8.5.2 Istio - Components of Istio](#852-istio---components-of-istio)
    + [8.5.3 Istio - How does it work?](#853-istio---how-does-it-work-)
    + [8.5.3 Istio - Why was it chosen?](#853-istio---why-was-it-chosen-)
    + [8.5.4 Istio - How was it implemented?](#854-istio---how-was-it-implemented-)
    + [8.5.5 Istio - Advantages](#855-istio---advantages)
    + [8.5.6 Istio - Disadvantages](#856-istio---disadvantages)
    + [8.5.7 Istio - Alternatives](#857-istio---alternatives)
  * [8.6 HashiCorp Vault](#86-hashicorp-vault)
    + [8.6.7 HashiCorp Vault - What is it?](#867-hashicorp-vault---what-is-it-)
    + [8.6.8 HashiCorp Vault - Components of Vault](#868-hashicorp-vault---components-of-vault)
    + [8.6.8 HashiCorp Vault - How does it work?](#868-hashicorp-vault---how-does-it-work-)
    + [8.6.9 HashiCorp Vault - Why was it chosen?](#869-hashicorp-vault---why-was-it-chosen-)
    + [8.6.10 HashiCorp Vault - How was it implemented?](#8610-hashicorp-vault---how-was-it-implemented-)
    + [8.6.11 HashiCorp Vault - Advantages](#8611-hashicorp-vault---advantages)
    + [8.6.12 HashiCorp Vault - Vault agent flow](#8612-hashicorp-vault---vault-agent-flow)
    + [8.6.13 HashiCorp Vault - Database engine flow](#8613-hashicorp-vault---database-engine-flow)
  * [8.7 External Secret Operator](#87-external-secret-operator)
    + [8.7.1 External Secret Operator - What is the problem?](#871-external-secret-operator---what-is-the-problem-)
    + [8.7.2 External Secret Operator - What is the solution?](#872-external-secret-operator---what-is-the-solution-)
- [9. User scenario: external access to Vault](#9-user-scenario--external-access-to-vault)
  * [9.1 Network Load Balancer (NLB)](#91-network-load-balancer--nlb-)
    + [9.1.1 Network Load Balancer - What is it?](#911-network-load-balancer---what-is-it-)
    + [9.1.2 Network Load Balancer - How does it work?](#912-network-load-balancer---how-does-it-work-)
    + [9.1.3 Network Load Balancer - Why was it chosen?](#913-network-load-balancer---why-was-it-chosen-)
    + [9.1.4 Network Load Balancer - How was it implemented?](#914-network-load-balancer---how-was-it-implemented-)
    + [9.1.5 Network Load Balancer - Advantages](#915-network-load-balancer---advantages)
    + [9.1.6 Network Load Balancer - Disadvantages](#916-network-load-balancer---disadvantages)
  * [9.2 Network Load Balancer - Target group and health check](#92-network-load-balancer---target-group-and-health-check)
  * [9.3 Route 53 Private Hosted Zone](#93-route-53-private-hosted-zone)
    + [9.3.1 Route 53 Private Hosted Zone - What is it?](#931-route-53-private-hosted-zone---what-is-it-)
    + [9.3.1 Route 53 Private Hosted Zone - Why was it chosen?](#931-route-53-private-hosted-zone---why-was-it-chosen-)
    + [9.3.1 Route 53 Private Hosted Zone - How was it implemented?](#931-route-53-private-hosted-zone---how-was-it-implemented-)
    + [9.3.2 Route 53 Private Hosted Zone - Advantages](#932-route-53-private-hosted-zone---advantages)
    + [9.3.3 Route 53 Private Hosted Zone - Disadvantages](#933-route-53-private-hosted-zone---disadvantages)
  * [9.4 VPN](#94-vpn)
    + [9.4.1 VPN - What is it?](#941-vpn---what-is-it-)
    + [9.4.2 VPN - Why was it chosen?](#942-vpn---why-was-it-chosen-)
    + [9.4.3 VPN - How was it implemented?](#943-vpn---how-was-it-implemented-)
- [10. Installation Guide](#10-installation-guide)
  * [10.1 Requirements](#101-requirements)
  * [10.2 Cloning the infrastructure repository](#102-cloning-the-infrastructure-repository)
  * [10.3 Terraform initialization](#103-terraform-initialization)
  * [10.4 GitOps-automation via FluxCD](#104-gitops-automation-via-fluxcd)
  * [10.5 Vault recovery on first bootstrap](#105-vault-recovery-on-first-bootstrap)
  * [10.6 GitLab-runner setup](#106-gitlab-runner-setup)
  * [10.7 VPN Configuration (for external access to Vault)](#107-vpn-configuration--for-external-access-to-vault-)
  * [10.8 Overview of the Deployment Flow](#108-overview-of-the-deployment-flow)
  * [10.9 Result](#109-result)
- [11. Conclusion and reflection](#11-conclusion-and-reflection)

# 1. Introduction

Modern secret management in cloud-native environments requires a fundamentally different approach than traditional methods. This project demonstrates a complete, production-ready implementation of HashiCorp Vault within a Kubernetes infrastructure on AWS.

The challenge: In dynamic container environments where applications are continuously deployed and scaled, managing secrets (API keys, database credentials, certificates) poses a significant security risk. Hardcoded credentials, plaintext configurations, or manual rotation are no longer acceptable in modern DevOps practices.

The solution: A fully automated, secure, and scalable secret management architecture that:
- Generates dynamic credentials with limited lifetime
- Implements zero-trust networking between all services
- Provides complete audit trails for compliance
- Seamlessly integrates with GitOps workflows

This document describes the complete implementation, from infrastructure setup to production-ready configuration, including all architecture decisions, security considerations, and practical troubleshooting guides.


# 2. Project Overview

This project implements an enterprise-grade secret management solution based on HashiCorp Vault within a multi-cluster Kubernetes architecture. The focus is on achieving a secure, scalable, and fully automated environment for managing sensitive data in cloud-native applications.

Core implementation components:

Secret Management: HashiCorp Vault as central secret store with support for:
- Dynamic database credentials with automatic TTL
- Kubernetes-native authentication via ServiceAccounts
- Automated secret rotation
- Fine-grained access policies

Infrastructure as Code: Complete AWS infrastructure via Terraform modules:
- Multi-cluster EKS setup with separation between application and tooling workloads
- Networking with private subnets and VPN access
- IAM roles and policies for least-privilege access

GitOps Automation: FluxCD for declarative deployment management:
- Automatic synchronization from Git repositories
- Helm release management
- Multi-cluster configuration

Security Architecture:
- Istio service mesh with mTLS and zero-trust policies
- Vault behind internal load balancer without public exposure
- Audit logging and compliance features

The implementation is designed for teams prioritizing security, scalability, and operational excellence within their Kubernetes environments.

# 3. System Architecture

![Systeemarchitectuur](img/system-architecture.png)

The infrastructure is entirely built within AWS and leverages several fundamental building blocks
for scalability, security, and manageability. To create a clear separation between application logic
and supporting infrastructure, we consciously chose to divide it into two separate Kubernetes
clusters (EKS): an application cluster and a tooling cluster. This approach enhances security,
simplifies management, and allows both environments to be scaled or maintained independently.

# 4. AWS Infrastructure

For application access, we use an Application Load Balancer (ALB) that routes HTTP traffic to the
frontend and backend of our application. This ALB ensures controlled and structured access to the
various application components.

In addition, we have set up an internal Network Load Balancer (NLB) that exposes port 8200 for
secure access to HashiCorp Vault. The NLB is exclusively reachable within the VPC and receives
traffic via a VPN connection, allowing Vault to be accessed securely externally without being
publicly available.

To make internal services like Vault easily accessible, we use Route 53 private DNS, where the
domain name `vault.internal` is linked to the URL of the Network Load Balancer.

# 5. Application cluster (EKS-application)

The application cluster contains the core services of a demo application: a frontend, a backend, and
databases. Within this cluster, a service mesh is also applied (via Istio) to secure and manage
internal communication between microservices. All components within this cluster use DNS resolution
via Route 53 to communicate with Vault via the internal domain `_vault.internal_`.

By separating these components from the infrastructure services, the development and runtime
environments remain purely separated, which improves stability and security.

# 6. Tooling cluster (EKS-tooling)

The tooling cluster includes HashiCorp Vault, FluxCD, and a self-hosted GitLab Runner, among others.
Vault acts as the central secret management system here, while FluxCD is responsible for the GitOps
automation of both clusters. The Network Load Balancer that exposes Vault is also located within
this cluster and is accessed internally, or externally via the VPN connection.

This structure creates a modular architecture that combines security and simplicity. Management
components such as Vault can be maintained or modified independently of applications, while
developers in the application cluster can focus on software development and deployment.

# 7. In-depth look at the tools used

## 7.1 Terraform (Infrastructure as Code)

### 7.1.1 Terraform - What is it?

Terraform is an open-source tool developed by HashiCorp that allows infrastructure to be managed
automatically via code. In place of manually creating resources in a cloud console, infrastructure
is described in a declarative language (HCL – HashiCorp Configuration Language). Terraform then
ensures that the desired state is achieved, regardless of the current state of the infrastructure.

### 7.1.2 Terraform - How does it work?

Terraform reads configuration files that describe what the infrastructure should look like: think
networks, compute resources, databases, roles, and policies. When executing a `terraform plan`,
Terraform compares the desired state (as defined in the code) with the existing infrastructure, and
proposes exactly those changes that are needed to make them match. The execution of `terraform
apply` ensures that these changes are effectively carried out.

### 7.1.3 Terraform - Why was it chosen?

Terraform offers a reliable, scalable, and repeatable way to manage cloud infrastructure. Within our
project, it was essential that the infrastructure:

- Could be fully automated
- Allowed for version control
- Could be split into reusable modules
- Could be deployed in different environments (application and tooling) without code duplication

Terraform is moreover the industry standard within Infrastructure as Code and aligns perfectly with
the other tools in our project, such as Helm and FluxCD. As Terraform, like Vault, is also from
Hashicorp, they work seamlessly together.

### 7.1.4 Terraform - How was it implemented?

Within this project, Terraform forms the central engine behind our entire AWS infrastructure. To
keep management scalable, clear, and reusable, we have split the configuration into separate
reusable modules and cluster-specific configurations. This structure ensures a clear separation
between generic infrastructure logic and project- or environment-specific parameters.

**Module library (modules/)**

In this central folder are all reusable modules, each responsible for one specific infrastructure
component:

- vpc: builds the basic network infrastructure with subnets, route tables, and gateways
- iam: manages roles, policies, and service accounts
- kms: generates and manages keys for secure storage and access
- efs: makes shared files available via Elastic File System
- eks: creates the Kubernetes cluster, including nodegroups and configuration

Each module contains three core files:
- `main.tf`: describes the resources that Terraform will create. This is the heart of the module.
- `variables.tf`: defines the input parameters needed to make the module flexible. Think here of
CIDR blocks, naming, instance types or regions.
- `outputs.tf`: returns selected values of the created resources to the higher-level configuration.
These outputs are often used as input for other modules or configurations (e.g., passing the VPC ID
to the EKS module).

This modular structure ensures that complex infrastructure remains traceable, adaptable, and
reproducible. We apply here the "80%-principle": each module supports the most common
configurations, but avoids overcomplication by not supporting every edge-case.

**Cluster-specific configuration**

Both the application cluster and the tooling cluster have their own folder structure with specific
main.tf files that call these modules. Within these configurations, we determine the concrete
parameters such as region, subnet IDs, names, CIDR blocks, or EKS node settings.

This division allows both clusters to be managed independently, make changes in isolation, or easily
create new environments (e.g., staging or a cluster in another region) by creating an additional
folder with different parameters, without any duplication of logic.

**Why a separate application and tooling cluster?**
We consciously chose to split the infrastructure into two separate EKS clusters — one for the
application, and one for tooling such as Vault, GitLab Runner and ESO — for the following reasons:

**1. Scalability**
The application cluster runs all microservices, frontend/backend and supporting services that are
subject to intensive scaling during peak load. By isolating tooling (such as Vault or GitLab Runner)
in a separate cluster, we prevent these crucial infrastructure components from having to scale
unnecessarily or be affected by autoscaling events in the app-cluster.

**2. Availability & Stability**
CI/CD and secret management must always remain available — even if the application itself is
restarted, scaled up or modified. By detaching this tooling from the workloads they manage, we
increase the stability and uptime of the platform as a whole.

**3. Security**
The isolation of clusters introduces a strong security boundary. For example, IAM policies, network
rules and Kubernetes RBAC can be strictly separated between users of the application cluster and
management systems in the tooling cluster. Vault, for example, should only allow traffic from
specific pods from the application cluster via the service mesh or a VPN connection.

**4. Independent lifecycle**
The tooling cluster evolves at a different pace than the application cluster. Upgrades, maintenance
or reconfigurations of, for example, GitLab Runner or ESO can be carried out without impact on
production services.

### 7.1.5 Terraform - Advantages

- Reusability: thanks to modular structure, the infrastructure is easily adaptable for other
environments or projects.

- Security and compliance: all resources are centrally managed and provided with consistent tags,
policies and lifecycle management.

- Version control: every change in infrastructure is managed via Git, with full visibility on who
changed what and when.

- Drift detection: Terraform detects discrepancies during runtime between the actual state and the
code, allowing us to quickly correct deviations.

- Scalability: new clusters or regions can be easily deployed by reusing existing modules with
adapted parameters.

### 7.1.6 Terraform - Disadvantages

- Terraform requires a clear structure and good documentation. Without these agreements,
configurations can quickly become chaotic.

- For complex resources or exceptions, sometimes a workaround or custom module is needed.

- Terraform has a learning curve; especially with error messages during apply, debugging is not
always evident.

## 7.2 Helm

### 7.2.1 Helm - What is it?

Helm is a widely used standard for k8s package management. It enables teams to deploy applications
and infrastructure components in a structured, repeatable way in a Kubernetes cluster with version
control capabilities. Helm makes it possible to bundle Kubernetes manifests (such as Deployments,
Services and ConfigMaps) into so-called charts, with which complex applications can be easily
managed.

### 7.2.2 Helm - Components of Helm

A Helm chart consists of various components that together determine the behavior of the
installation:
- `Chart.yaml`: Metadata of the chart (name, version, description).
- `values.yaml`: The standard configuration file where parameters are defined (such as version
numbers, ports, resources).
- `templates/`: Contains the Kubernetes manifests in Jinja-like template form. During installation,
these are filled with values from values.yaml.
- `Charts/` (optional): Subcharts that are included as dependencies.
- `Templates/_*.tpl`: Contains reusable template snippets, such as naming conventions.

This structure makes it possible to deploy the same chart in different environments (development,
staging, production) by simply entering different values via a customized values.yaml file or CLI
parameters.

### 7.2.3 Helm - How does it work?
Helm takes the templates from a chart and combines them with values from the values.yaml file.
During a helm install or helm upgrade, the generated output is pushed to Kubernetes as standard YAML
manifests. Because Helm supports version control, previous releases can easily be rolled back with
helm rollback.

Helm stores metadata of each release in its own namespace (via secrets or ConfigMaps), so it knows
exactly which version of a chart is installed, including associated values and status.

### 7.2.4 Helm - Why was it chosen?

Helm fits seamlessly with the principles of GitOps and Infrastructure as Code. Within our project,
Helm provides a solution for:
- Standardized deployments of applications such as Vault, Istio, FluxCD and GitLab Runner
- Reusability and parameterization of configurations
- Version control of releases per environment (application cluster, tooling cluster)
- Integration with FluxCD, so that everything can be controlled and rolled out from Git

### 7.2.5 Helm - How was it implemented?

In our architecture, Helm is the standard tool to manage and deploy Kubernetes resources, both for
infrastructure components and for application services. The implementation comprises multiple
layers:

**Installation and management via FluxCD**

All Helm charts are deployed via HelmRelease resources in combination with FluxCD. This means that
the desired state of each Helm chart is described in Git, and that every change is automatically
synchronized to the correct cluster.

For each cluster (application and tooling) separate HelmRelease files have been set up that refer
to:

- an external chart repository (such as Hashicorp/Vault or istio.io),
- or an internal chart folder in the Git repo (for own charts).

Flux detects changes in the chart version or in the values.yaml file, and automatically triggers a
helm upgrade.

**Custom values per cluster and environment**

The configuration of each chart is done via a values.yaml file that is in the Git repository. For
example, within the tooling cluster, we use customized values for Vault (such as nodeSelector,
service type, storage backends), while the application cluster runs with its own Istio configuration
(such as ingress gateways and mesh policies).

**Consistent naming and labels**

Via helpers.tpl and conventions in values.yaml, we ensure that resources are neatly grouped and
labeled per environment, which significantly simplifies management.

**Upgrades, rollbacks and debugging**

In case of issues, we can easily roll back to a previous release via helm rollback. Because each
HelmRelease contains an exact chart version and configuration, the behavior of a release is
perfectly reproducible.

### 7.2.6 Helm - Advantages

- **Reusability:** the same chart can be deployed across multiple environments with adapted
parameters
- Version control: each release is traceable and can be rolled back
- Automation: integrates seamlessly with GitOps via FluxCD
- Scalability: easily applicable to tens or hundreds of components
- Manageability: clear structure of values and configuration per component

### 7.2.7 Helm - Disadvantages

- **Complex templating:** for large charts with many conditions or logic, the template behavior can
be difficult to understand

- **Debugging** of generated manifests is sometimes cumbersome; helm template is then needed to
inspect the effective output

- **Dependency on chart quality:** poorly constructed or insufficiently documented charts from
external repositories can make management difficult

By using Helm as the standard deployment mechanism, combined with FluxCD, we have created a
controllable and scalable release pipeline. It enables us to manage, audit and, if necessary,
restore all components — from Vault and Istio to internal services — in a consistent manner.

## 7.3 GitOps (FluxCD)

### 7.3.1 FluxCD - What is it?

FluxCD is an open-source GitOps tool for Kubernetes that ensures the state of a cluster always
matches the configuration as it is in a Git-repository. Instead of manually applying Kubernetes
manifests via kubectl, FluxCD makes it possible to automatically apply configuration changes based
on changes in Git. This provides more security, traceability and automation.

FluxCD functions as a pull-based Continuous Delivery system that periodically scans the
Git-repository for changes and automatically implements these changes in the cluster. This promotes
consistency, auditability and self-healing behavior. Flux also offers the possibility to perform a
rollback. This makes it easy if the new configuration contains errors and needs to be set back to a
previous version.

### 7.3.2 FluxCD - Components of FluxCD
Flux consists of a number of separate Kubernetes controllers, each with a specific responsibility:

- **Source Controller:** Synchronizes Git-repositories or Helm-repositories to the cluster
- **Kustomize Controller:** Applies Kustomize-manifests that are in the Git-repo
- **Helm Controller:** Manages HelmReleases and automatically performs helm upgrade.
- **Notification Controller:** Sends notifications (Slack, email, webhook) about changes or errors
- **Image Automation Controller (optional):** Automatic image tag updates in Git with new builds
- **Image Reflector Controller (optioneel):** Fetching new image tags from a repo

### 7.3.3 FluxCD - How does it work?

FluxCD uses a declarative approach: you describe in Git how your infrastructure and applications
should look. The controllers of FluxCD constantly compare the current state of the cluster with this
desired state and ensure that the cluster is adjusted where necessary.

A typical workflow:

1. Developer commits a new version of a HelmRelease/manifest in Git.
2. FluxCD detects this change.
3. The Helm/source Controller performs a helm upgrade/manifest change with the new values.
4. The cluster is now up-to-date with the latest Git version.

```mermaid
flowchart TD
A[Git]
B[Flux Controller]
C[Kubernetes Cluster]
D[Application Pods]

A -- Flux synx watches Git --> B -- Pulls updated manifests --> C -- Deploy updated pods with new
image tag --> D
```

### 7.3.4 FluxCD - Why was it chosen?

We chose FluxCD for the following reasons:

- **Kubernetes-native:** It runs entirely in the cluster without external components
- **Lightweight and modular:** Only the necessary controllers are installed
- **Simple Git-integration:** No extra tooling needed such as webhooks or pipelines
- **Good Helm-support:** Seamless integration with our Helm-charts
- **Secret management:** FluxCD can be easily combined with HashiCorp Vault (via Vault Secrets
Operator or SOPS)
- **Version control:** if desired, we can easily perform a rollback to an earlier version

### 7.3.5 FluxCD - How was it implemented?

FluxCD was deployed by us via Terraform using the official Flux Terraform provider. For each cluster
(both tooling and application) a separate GitOps folder was created:

- Authentication via SSH: The Git-repository is accessed via SSH (no HTTPS), with a private key
inserted via Terraform (flux_git_ssh_private_key_path)
- Flux-configuration as Terraform resource: Each Flux-installation is fully automated with
declarative code:

```terraform
provider "flux" {
  kubernetes = {
    host = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_ca)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command = "aws"
    }
  }
  
 git = {
    url = "ssh://${var.git_repo_ssh}"
    branch = var.git_branch
    ssh = {
      username = "git"
      private_key = file(var.flux_git_ssh_private_key_path) 
    }
  }
}
```

- **HelmReleases per environment:** In our Git-repo are multiple HelmRelease-manifests, split per
component (Vault, Istio, GitLab Runner, etc.) and per cluster

- **Automatic sync:** Every change in the Helm-release, manifests or values.yaml is automatically
deployed by FluxCD to the correct environment

This way, we manage both clusters fully Git-driven: changes are made via Pull Requests.

**Internal workings of FluxCD - Controller Flow**

The internal workings of FluxCD are modularly built around a number of specialized controllers, each
performing its own task in the GitOps chain. This structure allows changes from Git to be applied
fully automatically and in a controlled manner within Kubernetes.

Step-by-step flow:

**1. Git-repository:**

The workflow starts with a Git repository where all declarative YAML manifests or HelmRelease
resources are stored. This is the single source of truth for all Kubernetes resources within the
cluster.

**2. Source Controller**

This controller is responsible for fetching external sources such as Git-repositories or
Helm-repositories. It periodically scans the specified Git-branch and downloads the content
(YAML-manifests or Helm charts) to a local artifact in the cluster. This artifact contains the last
known and validated configuration.

**3. Artifact production**

After fetching the Git content, a renderable artifact is created from it that serves as input for
the next step. This artifact contains all generated manifests that can actually be applied.

**4. Controllers**

The controllers are responsible for interpreting and applying the content of the artifact created by
the Source Controller. They process the declarative configuration and translate it into concrete
Kubernetes resources.

**5. Cluster Resources**

the Controllers send their output directly to the Kubernetes-cluster, where the desired state is
applied. Through this continuous cycle of polling, comparing and updating, Flux guarantees that the
cluster always remains synchronous with the Git-repository.

This division into controllers makes FluxCD robust, scalable and easy to debug: each component does
exactly one task, and troubleshooting therefore remains clear. In our project, we mainly use the
Source Controller and Helm Controller, because all our applications and infrastructure components
are rolled out via HelmReleases.

```mermaid
flowchart TD
subgraph Git Repositories 
GitRepository[Git Repository - YAML manifests]
end
    
subgraph Flux Controllers 
SourceControllers[Source Controllers]
Controllers
end

subgraph Kubernetes Cluster 
ClusterResources[Cluster Resources]
end

GitRepository -- polls --> SourceControllers
SourceControllers -- produces --> Artifact[Artifact - rendered source]
Artifact --> Controllers
Controllers -- applies --> ClusterResources
```

**Image automation - Automatic updates of container images**

An optional, but powerful extension of FluxCD is the Image Automation-system, which can
automatically detect, process and apply changes in container images in Git. Instead of manually
adjusting a new image-tag in YAML-files, this feature allows the correct tag in Git to be
automatically updated, keeping the full GitOps-flow intact.

**Working of image automation:**

**1. Image Reflector Controller**

This controller monitors a container registry (such as ECR, Docker Hub or GitLab Container Registry)
at fixed intervals and retrieves the available tags of a specified image.

**2. Image Repository:**

The tags of the image are stored locally in a Kubernetes custom resource named Image Repository.
This resource forms the data source for further filtering and evaluation.

**3. Image Update Policy**

Via this policy, you indicate based on which criteria (for example: latest, semver, regex) a new tag
is considered "update-worthy".

**4. Image Automation Controller**

As soon as a new suitable image-tag is recognized, this controller adapts the corresponding
manifest-file in the Git-repository. For example, if `frontend:1.3.0` becomes available in the
registry, the `image.tag` in the YAML-file is automatically updated.

**5. Git Push & Git Update**

After this adjustment, the Image Automation Controller executes a commit and push to the
Git-repository. This reactivates the standard FluxCD flow: Source Controller detects the change →
Helm Controller executes an upgrade → Kubernetes gets the new version rolled out.

### 7.3.6 FluxCD - Advantages
- Fully Git-based management with version control
- Self-healing: automatically recovers from deviations from the Git-state
- Multi-cluster support: easy to set up with one Git-repo for multiple clusters
- Integration with Helm simplifies lifecycle management of applications
- Easily extendable with notifications, secrets and image automation

### 7.3.7 FluxCD - Disadvantages
 
- No built-in GUI (unlike ArgoCD), which makes debugging more difficult for beginners

- Less direct feedback: you have to use logs or the CLI to see status

- Initially slightly more complex setup compared to simple CI/CD pipelines

**Alternatives**

- ArgoCD: Offers a rich web interface and is very suitable for teams who want visual control over
their deployments. ArgoCD, however, requires more resources and more complex setup, especially in
multi-cluster environments.

- Jenkins X: Combines CI/CD into one framework, but is heavier, more difficult to maintain and less
Kubernetes-native.

- Fleet (from Rancher): Aimed at very large multi-cluster environments, but less suitable for
small/medium-sized teams.
For our project, FluxCD was the best choice due to its simplicity, native Kubernetes integration and
seamless compatibility with Helm and Vault.

For our project, FluxCD was the best choice due to its simplicity, native Kubernetes integration and
seamless compatibility with Helm and Vault.

## 7.4 - Self-hosted GitLab runner

### 7.4.1 GitLab runner - What is it?

The GitLab Runner is an open-source component of GitLab that is responsible for executing CI/CD
pipelines. It is the engine that effectively performs tasks such as building, testing and deploying
applications. A runner can be used in various ways — from a simple virtual machine to a container
in a Kubernetes cluster. In our project, we chose a self-hosted runner that runs as a Kubernetes
workload within the tooling cluster. We opted for a self-hosted runner because it allows us to
execute unlimited jobs without incurring costs.

### 7.4.2 GitLab runner - Components of Gitlab Runner

The GitLab Runner installation includes:

- Runner Agent: the process that fetches jobs from GitLab and executes them.
- Executor: the mechanism with which tasks are executed (e.g. docker, shell, kubernetes).
- ServiceAccount + RBAC: needed to create and manage pods within Kubernetes.
- Helm Chart: to install and manage the runner as a Kubernetes workload.
- Secrets/Registration Token: authentication to connect to the correct GitLab project runner.

### 7.4.3 GitLab runner - How does it work?

When a developer makes a commit on GitLab, this triggers a pipeline defined in the .gitlab-ci.yml.
GitLab sends this job to a registered runner. Our runner runs in Kubernetes and uses the kubernetes
executor. Upon receiving a job, the runner creates a pod with containers responsible for the build,
tests and any deploy tasks. Once the job is finished, the pods are automatically cleaned up.

### 7.4.4 GitLab runner - Why was it chosen?

We chose a self-hosted GitLab Runner in Kubernetes for several reasons:
- **Full control** over the execution and configuration of CI/CD tasks.
- **Scalability:** Kubernetes can easily run multiple builds in parallel.
- **Integration with Vault:** we can securely inject secrets during jobs.
- **Cost-conscious:** by not using shared runners, we avoid limitations on speed or number of
minutes.
**Flexible configuration:** such as the use of custom images, node selectors and resource limits.

### 7.4.5 GitLab runner - How was it implemented?

Our GitLab Runner is deployed within the tooling cluster via a fully GitOps-driven workflow. The
runner is responsible for executing CI/CD pipelines — with emphasis on building container images
with Podman and pushing to AWS ECR.

We consciously chose Podman instead of traditional Docker-based solutions. Podman is a daemonless
container engine that is compatible with the Docker CLI, but safer and better suited for Kubernetes
environments. Because Podman does not require a background process (like the Docker daemon), we can
execute builds without root privileges — which lowers the attack surface and better aligns with
the security best practices of cloud-native infrastructure. Moreover, Podman supports full OCI
compatibility and integrates seamlessly with rootless container builds.

Our runner uses a custom image (c1sv3r/aws-podman:1.0) in which both Podman and AWS CLI are
installed. This enables us to:

- Build Container Images with podman build
- Authenticate with AWS ECR via the AWS CLI
- Push the images with podman push

**1. Git repository & Kustomizations**

The GitRepository fetches the configuration from the tooling-gitops repo that contains the runner.
This repo is periodically polled by Flux:

```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: gitlab-runner-repo
spec:
  url: ssh://git@gitlab.com/...
  interval: 1m
  ignore: |
    /*
    !/tooling/gitlab-runner/**
```

Subsequently, there are two Kustomizations:
- **gitlab-runner-secrets:** manages the necessary secrets, including the registration-token via
Vault

- **gitlab-runner-bootstrap:** installs the HelmRelease for the runner and injects values via
postBuild.substituteFrom

**2. HelmRelease-configuration**

The runner is declared with a HelmRelease, which refers to the official GitLab Helm chart:


```yaml
chart:
  spec:
    chart: gitlab-runner
    version: 0.64.0
    sourceRef:
      kind: HelmRepository
      name: gitlab
```

The values-section defines among others:

- `gitlabUrl`: the GitLab-host that is used
- `runnerRegistrationToken`: the secret token that has been retrieved via Vault
- `rbac` and `serviceAccount`: including IAM role for access to AWS (EKS) and ECR
- `runners.executor`: on kubernetes, which executes jobs as pods
- `resources`: CPU and memory limits for builds
- `config`: advanced settings for logs, timeout, concurrency and more


**3. Secrets via External Secrets Operator (ESO)**

The registration-token comes from Vault, via an ExternalSecret resource:

```yaml
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: gitlab-runner-token
spec:
  secretStoreRef:
    name: vault-backend
  data:
    - secretKey: REGISTRATION_TOKEN
      remoteRef:
        key: kv/gitlab/runner
        property: registrationToken
```

Thus we guarantee that sensitive data is not hardcoded in our repository and is only available
during runtime.

### 7.4.6 GitLab runner - Alternatives

**1. Docker (classic daemon)**
Docker is the best-known container engine and the standard in many CI environments.

**Advantages:**

- broadly supported, familiar CLI-pattern, much documentation

**Disadvantages:**

- Requires a running Docker-daemon (root privileges or privileged mode)
- Difficult to integrate into rootless containers in Kubernetes
- Security concerns when using a shared daemon

**Why not chosen:** It requires a privileged pod or sidecar to make the daemon available, which is
contrary to our security principles.

**2. Kaniko**

Kaniko is an open-source tool from Google for building container images within a container or
Kubernetes-cluster, without the need for a daemon.

**Advantages:**
- fully daemonless, suitable for Kubernetes, secure

**Disadvantages:**
- Slower than Podman for large builds
- No full compatibility with certain more complex Dockerfiles
- Less configuration freedom and debugging possibilities
Why not chosen: The support from Google was stopped last year, which in our opinion makes it not a
robust and long-term alternative.

**3. Buildah**

Buildah is a low-level image builder, also from the makers of Podman.

Advantages:

- native OCI-support, highly modular, rootless support

Disadvantages:
- Less user-friendly than Podman
- No drop-in replacement for docker build (other syntax)
- Less community-support for integration into GitLab

- Why not chosen: Buildah is especially interesting for advanced CI/CD pipelines with complex
scripting. Podman offers the same advantages, but is more user-friendly and better compatible with
existing Docker workflows.

### 7.4.7 GitLab runner - Advantages

- **Full integration with GitLab** via Helm
- **Scalable:** jobs are executed as isolated pods in Kubernetes
- **Secure secrets:** thanks to Vault and ESO
- **Flexible configuration:** including RBAC, namespaces, dedicated serviceaccount and
IAM-integration
- **Fully GitOps-compatible:** deployed via FluxCD

### 7.4.8 GitLab runner - Disadvantages

- **Complexity:** installation requires knowledge of Helm, FluxCD and Vault-integration.
- **Management:** requires monitoring and logging of job-failures in its own cluster.
- **Maintenance:** chart and token upgrades require coordination with the GitLab-interface.
- **Network restrictions:** Runner must be able to connect to gitlab.com (for private
GitLab-instances this can be more challenging).

---

## 7.5 Service Mesh (Istio)

### 7.5.1 Istio - What is it?

Istio is an open-source service mesh that manages and secures communication between microservices
within a Kubernetes-cluster without you having to adapt the services themselves. This happens by
using so-called sidecar proxies (usually Envoy), which run next to each service and intercept all
traffic. This allows security, observability, traffic management and access control to be applied
centrally and uniformly.

### 7.5.2 Istio - Components of Istio

Istio consists of multiple components that together realize the service mesh concept:
- **Istiod (Control Plane):** Responsible for service discovery, configuration, and certificate
management. It pushes configurations to the sidecars.

- **Envoy sidecar proxy (Data Plane):** Is automatically injected into each pod and functions as an
intermediary for all incoming and outgoing traffic. Performs tasks such as mTLS, retries, circuit
breaking and metrics.
- **Ingress/Egress gateways:** Manage all traffic entering (ingress) or leaving (egress) the mesh.
We use an Ingress Gateway for external access.
- **VirtualServices:** Declarative rules for routing traffic to the correct backend-service.
- **DestinationRules:** Determine how traffic to a specific service is handled (e.g., mTLS, load
balancing).
- **AuthorizationPolicies:** Determine which services or service accounts are allowed to access
other services within the mesh.

### 7.5.3 Istio - How does it work?

Each pod in an Istio-enabled namespace automatically gets an Envoy sidecar-container that intercepts
all communication with other pods. These proxies communicate with Istiod, which provides the
configuration, service discovery, policies and TLS-certificates. This allows functions such as mTLS
(mutual TLS), retries, timeouts, circuit breaking, and traffic shaping (canary releases, A/B
testing) to be applied without code changes.

For example, when service A sends a request to service B, this request goes via the Envoy-proxy of
A, through the mesh, to the Envoy-proxy of B, after which the request is delivered to the actual
application container. This path is controlled based on configured policies.

### 7.5.3 Istio - Why was it chosen?

The choice for Istio in this project was driven by the need to implement zero-trust networking,
detailed observability and central management of network traffic within the application cluster.
Instead of writing individual network rules and policies per microservice, Istio offers a consistent
model where encrypted communication, access control and monitoring are integrated by default.

Moreover, Istio is widely adopted in the industry, with extensive documentation and an active
community. Since it is considered graduated by CNCF (Cloud Native Computing Foundation), Istio is
also suitable for production environments and complex scenarios.

### 7.5.4 Istio - How was it implemented?

The full deployment of Istio within our application cluster is declarative and GitOps-driven,
managed via FluxCD in combination with HelmReleases. The configuration is split into logical
components for overview, maintainability and reusability. All manifests are stored in a central
Git-repository, from which FluxCD automatically synchronizes them to the cluster.

**1. HelmRepository-configuration**

We started by defining a HelmRepository resource that refers to the official Istio Helm chart
repository. This is located in the istio-system namespace:

```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: HelmRepository
metadata:
  name: istio
  namespace: istio-system
spec:
  url: https://istio-release.storage.googleapis.com/charts
  interval: 1m
```

This repository serves as the source for installing the Istio-components via HelmReleases.

**2. Installation of Istio via HelmReleases**
The installation is split into two HelmReleases:
- Istio-base installs the necessary CRDs (Custom Resource Definitions).
- Istiod installs the control plane and configures mesh-specific parameters such as access to stdout
logging:

```yaml
values:
  meshConfig:
    accessLogFile: /dev/stdout
```

These HelmReleases are followed up via FluxCD and automatically synchronized with every change.

**3. Sidecar-injection**

The app namespace is configured with the label istio-injection=enabled, so that all pods
automatically get an Envoy sidecar. This makes it possible to manage, secure and observe traffic
between microservices without having to modify the application code.

**4. Routing via VirtualServices**
For each microservice in the cluster (such as assets, carts, catalog, checkout, orders, ui) we have
defined our own VirtualService. These configurations determine how internal traffic is routed to the
correct service.
Example — VirtualService for the catalog microservice:

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: catalog
  namespace: app
spec:
  hosts:
    - catalog
  http:
    - route:
    - destination:
        host: catalog.app.svc.cluster.local
        port: 
        number: 8080
```

The ui service is the only one that contains a gateway: mesh and a URI-prefix match (/), so that it
can also function as an access point to the rest of the application.

**5. ServiceAccounts per microservice**

Each microservice has received its own ServiceAccount, which is essential for enforcing access
rights via Istio Authorization Policies:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: checkout-sa
  namespace: app
```

This subdivision makes it possible to apply access rules at a very detailed level, based on the
identity of the client-pod (via principal).

**6. PeerAuthentication - enforcing mTLS**

To enforce encryption and verification of service traffic, we have created a PeerAuthentication
resource in the app namespace:

```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: app
spec:
  mtls:
    mode: STRICT
```

This configuration ensures that only mutual TLS (mTLS) connections are allowed between pods in the
cluster. Traffic without a sidecar or valid certificate will be rejected.

**7. Default-deny AuthorizationPolicy - block everything**

To consistently implement the zero-trust principle, we defined a standard AuthorizationPolicy
without any rules — which initially blocks all communication:

```yaml
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: deny-all
  namespace: app
spec: {}
```

This default-deny policy ensures that no service may communicate with another, unless this is
explicitly allowed.

**8. Security with Authorization Policies**

For each relevant interaction between microservices an inbound policy has been set up. These
policies define exactly which services may communicate with each other, and based on which
ServiceAccounts.

For example — only the assets-sa service may communicate with the activemq service:

```yaml
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: allow-assets-to-activemq
  namespace: app
spec:
  selector:
    matchLabels:
    app: activemq
action: ALLOW
rules:
  - from:
  - source:
      principals: ["cluster.local/ns/app/sa/assets-sa"]
```

Also inbound policies are defined for the assets-service. For example: the ui service may
communicate with assets:

```yaml
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: allow-assets-inbound
  namespace: app
spec:
  selector:
    matchLabels:
      app: assets
  action: ALLOW
  rules:
    - from:
    - source:
        principals: ["cluster.local/ns/app/sa/ui-sa"]
```

This zero-trust approach guarantees that only authorized communication takes place within the
cluster.

Thanks to this setup, we have set up a fully secured, dynamically configurable and well-controlled
service mesh, in which all interactions are explicitly defined — and are fully managed from Git.
The combination of FluxCD, Helm and Istio makes our mesh consistent, transparent and auditable.

### 7.5.5 Istio - Advantages

- **Security:** Automatic mTLS and policies per serviceaccount.
- **Control:** Full management over internal traffic without code changes.
- **Scalability:** Policies and routing are easily expandable to new services.
- **Transparency:** Metrics, logs and traces without extra instrumentation.
- **GitOps-friendly:** Fully declaratively manageable via FluxCD and Helm.

### 7.5.6 Istio - Disadvantages

- **Complexity:** Configuration requires in-depth knowledge of Kubernetes AND Istio-
- **Resource usage:** Each Envoy sidecar adds CPU and memory usage.
- **Management:** Policies and routing rules can quickly become extensive with many microservices.

### 7.5.7 Istio - Alternatives

| Feature                    | Istio       | AWS App Mesh | Linkerd    | Consul Connect |
|----------------------------|-------------|--------------|------------|----------------|
| Complexity                 | ⚠️ High     | ✅ Low        | ✅ Low      | ⚠️ Medium      |
| Performance overhead       | ⚠️ High     | ✅ Low        | ✅ Low      | ⚠️ Medium      |
| Security (mTLS, ACLs)      | ✅ Very good | ✅ Good       | ✅ Basic    | ✅ Good         |
| Observability              | ✅ Excellent | ⚠️ Limited   | ⚠️ Basic   | ⚠️ Limited     |
| Traffic management         | ✅Advanced   | ⚠️ Limited   | ✅ Basic    | ✅ Advanced     |
| AWS-integration            | ⚠️ Possible | ✅ Very good  | ⚠️ Limited | ⚠️ Limited     |
| Hybrid/multi-cloud support | ⚠️ Limited  | ❌ AWS only   | ⚠️ Limited | ✅ Excellent    |

Although some alternatives are simpler in design, Istio offers the most complete and flexible
solution for our project. It enables us to not only manage traffic and security, but also to
centrally enforce observability, service-identity and network behavior in a scalable manner.

---

## 7.6 HashiCorp Vault

### 7.6.7 HashiCorp Vault - What is it?

HashiCorp Vault is an advanced, open-source solution for secret management and identity-based access
control within cloud-native environments. It enables developers and operators to securely and
dynamically manage secrets (such as API keys, database passwords, TLS certificates and tokens) —
both statically and dynamically. Vault offers a central platform with support for encryption, audit
logs, fine-grained access control and integration with numerous systems such as Kubernetes, AWS IAM
and databases.

### 7.6.8 HashiCorp Vault - Components of Vault

The Vault-architecture in our project is built from multiple collaborating components, each with a
clear responsibility within the secret management process. Together, they ensure a secure, automated
and scalable approach to managing secrets in a Kubernetes environment. Below, we explain the most
important components:

**Vault**
The Vault forms the heart of the solution. It is the central service responsible for the storage,
encryption and access to all secrets. Within our architecture, Vault is set up as a
Kubernetes-service via a Helm chart in the tooling cluster, and thus runs fully in-container within
our infrastructure. Vault manages the secret backends (such as databases and key-value stores),
performs authentication and processes all access requests.

**Secrets Engines**

Vault supports various types of "Secrets Engines" which each fulfill a specific task. In our
project, we make use of the following two engines:

**- Key-Value (KV) Engine**

The KV-engine functions as a simple, encrypted key-value store for storing static secrets such as
API-tokens, registration-tokens for GitLab Runner and configuration data. This engine is suitable
for secrets that are managed manually or via Terraform and rarely change.

**- Database Secrets Engine**

This engine allows Vault to dynamically create temporary database users with limited rights and a
TTL (Time To Live). With each request, Vault generates a unique username/password-combination that
is automatically revoked after expiration. This significantly increases security compared to
hardcoded database credentials.

**Authentication Method**

**- Kubernetes Auth Method**

This method uses the built-in Kubernetes ServiceAccounts to authenticate pods with Vault. Pods
present a JWT-token that Vault validates via the Kubernetes API. Based on predefined Vault Roles,
the correct access is granted. This method is ideal for Kubernetes-native workloads and supports
dynamic secrets and fine-grained access control.

**- AppRole Auth Method**

AppRole is a method aimed at machines or applications that cannot automatically authenticate via a
platform identity. It works with a combination of role_id and secret_id that the application must
use to gain access to Vault. This is especially suitable for non-Kubernetes environments or legacy
applications.

**- AWS IAM Auth Method**

This method uses AWS IAM-roles and -policies to verify the identity of an EC2-instance,
Lambda-function or other AWS-resources. The application requests a Vault-token by making an
IAM-signed request, eliminating the need for separate credentials. This is useful for applications
running in AWS that want to use Vault.

| Feature                   | Kubernetes auth method              | AppRole auth method            | AWS IAM auth method             |
|---------------------------|-------------------------------------|--------------------------------|---------------------------------|
| **Usage Scenario**        | Kubernetes-native workloads         | Machines / legacy apps         | AWS cloud workloads             |
| **Authentication**        | JWT token via Kubernetes API        | Role ID + Secret ID            | IAM-signed request              |
| **Credential Management** | No extra credentials in pods        | Requires secret_ids management | No extra credentials (IAM role) |
| **Dynamic Secrets**       | Fully supported                     | Supported                      | Supported                       |
| **Integration with K8s**  | Full                                | Not specific                   | Limited, extra tooling needed   |
| **Management Complexity** | Relatively low (native K8s tooling) | Medium (secret distribution)   | Low (AWS IAM policies)          |
| **Security Model**        | Zero trust, identity based          | Secret-based                   | Identity via AWS infrastructure |
| **Suitable for**          | Containerized apps in Kubernetes    | Traditional or external apps   | AWS-based applications          |

**Why did we choose Kubernetes Auth Method?**

Our choice for the Kubernetes Auth Method is primarily motivated by the fact that our applications
run entirely within a Kubernetes cluster. The Kubernetes Auth method offers seamless and secure
integration by leveraging ServiceAccounts and the Kubernetes API for authentication. This means that
no static credentials need to be stored in the pods, which significantly reduces the risk of leaks.

In addition, this method provides fine-grained access control via Vault Roles, linked to Kubernetes
namespaces and service accounts, making rights management clear and scalable. Through this native
integration, we can also fully automate dynamic secrets, which aligns with our ambition for security
and operational excellence.

In short, the Kubernetes Auth Method offers the best balance between security, ease of use and
manageability within our cloud-native Kubernetes environment.

**Vault Agent Injector**

The Vault Agent Injector is a mutating admission webhook that automatically adds a sidecar-container
to each pod with the correct annotations.

**Vault Agent**

Vault Agent authenticates with Vault via Kubernetes-auth and retrieves the necessary secrets. The
secrets are then made available as temporary files in the pod. This ensures secure injection without
secrets having to be stored in the Kubernetes API. The agent also supports auto-renewal of leases
for dynamic secrets and templating of file content.

**Helm + FluxCD**

The full installation and configuration of Vault is declarative via Helm and is managed by FluxCD.
Helm is used for installing Vault itself as a Kubernetes-resource, while FluxCD via GitOps ensures
automatic synchronization with our Git-repository. This makes all Vault changes fully manageable
with versions, reproducible and consistent across environments. Flux triggers, among other things,
the installation of Vault, the setup of authentication, secrets engines, policies and init jobs.

### 7.6.8 HashiCorp Vault - How does it work?

Vault is deployed in the tooling cluster with the help of Helm and is managed by FluxCD. The
deployment follows these steps:

1. HelmRelease installs Vault via FluxCD, including init-jobs and configuration.
2. Vault is automatically unsealed via an init Job, so that all HA-instances can join the primary
Vault.
3. Kubernetes authentication is configured.
4. Secrets Engines are activated, such as kv-v2 and database.
5. Policies are written for access to specific secret paths.
6. Vault Agent Injector places a sidecar in pods that contain the correct annotations. This sidecar
retrieves secrets from Vault and injects them as files.
7. Pods that use secrets are automatically restarted when new credentials are generated (for
example, after rotation of database-users).

Secrets are therefore never stored in the Kubernetes API, and thanks to dynamic credentials, risks
of misuse or leakage remain limited.

### 7.6.9 HashiCorp Vault - Why was it chosen?

We chose HashiCorp Vault because of:

- **Support for dynamic secrets:** Specifically, database-users are created on-the-fly and
automatically expire.
- **Flexible authentication:** Via Kubernetes-auth, we can regulate access at the namespace and
service account level.
- **Security:** Secrets are not stored in plaintext in Kubernetes, and credentials have a short TTL
- **Integration with GitOps:** Thanks to Helm and Flux, everything is declarative and manageable
with versions.
- **Scalability:** Vault is designed for high availability and is easily extensible to multiple
clusters.

### 7.6.10 HashiCorp Vault - How was it implemented?

The implementation of HashiCorp Vault in our project is carefully built around security, automation,
and integration with GitOps principles. Through a combination of Terraform, Helm, FluxCD, and
Kubernetes-init-jobs, we have set up a fully reproducible and dynamic secret management solution.

**1. Deployment via Helm and FluxCD**

Vault is set up as a HelmRelease within the tooling cluster, managed by FluxCD. The HelmRelease is
driven from a GitOps repository and retrieves its chart from the official HashiCorp Helm repository.
All values for the configuration are delivered via a Kubernetes Secret (vault-helm-values), so that
sensitive configuration data (such as storage-backend or nodeSelectors) is not visible in plain YAML
in Git.

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: vault
  namespace: vault
spec:
  interval: 5m
  chart:
    spec:
      chart: vault
      version: "0.30.0"
      sourceRef:
        kind: HelmRepository
        name: hashicorp-helm
        namespace: repos
      valuesFrom:
        - kind: Secret
          name: vault-helm-values
          valuesKey: values.yaml
```

After installation, Vault runs as a StatefulSet with persistence (EFS), and in HA-configuration for
production use. Subsequently, Vault is automatically unsealed via a KMS key that was previously
created by Terraform.

**2. Initialization via Init Job**

After deployment, Vault is initially not yet ready for use: it must first be initialized. This
happens via Kubernetes init-job, which is automatically executed by Flux.

shell
vault operator init -format=json > /vault/init.json


**3. Configuration of Vault**

The configuration of Vault happens via the CLI (vault command) or the web interface (UI). In our use
case, most of the configuration has been performed via the CLI within a Kubernetes-cluster. Below,
we briefly review the steps we have performed:

**Kubernetes auth**
To allow Vault to communicate with workloads in Kubernetes (e.g., applications or GitLab Runners),
Kubernetes authentication must be enabled.

```shell
# Enable
vault auth enable kubernetes

vault write auth/kubernetes/config \
  token_reviewer_jwt="$JWT_TOKEN" \
  kubernetes_host="$KUBE_HOST" \
  kubernetes_ca_cert="$CA_CERT"

# Role declaration for auth
vault write auth/kubernetes/role/gitlab-runner \
  bound_service_account_names=gitlab \
  bound_service_account_namespaces=gitlab \
  policies=gitlab-policy \
  ttl=24h
```

```hcl
# Policy example
# gitlab-policy.hcl
path "kv/data/gitlab/api" {
  capabilities = ["read"]
}
```

```shell
vault policy write gitlab-policy gitlab-policy.hcl
```

**Enable secret engines**

Secret Engines are plug-ins in Vault that manage different types of secrets (such as KV, databases,
PKI, etc.).

```shell
vault secrets enable -path=kv kv-v2
vault secrets enable database
```

In our setup, we primarily use the KV v2-engine for static secrets and the database engine for
dynamic database credentials.

**Configuring key value secrets**

The Key-Value (KV) engine is used for storing simple key value-pairs such as API-keys or tokens.

```shell
vault kv put kv/gitlab/api \
  token=ghp_abc123xyz456 \
  url=https://gitlab.example.com
```

Access to these secrets is controlled via policies that are linked to specific roles.

**Configuring Database secrets**

The Database Secret Engine is used for dynamically creating user accounts with temporary credentials
in for example PostgreSQL or MySQL.

```shell
vault write database/config/my-postgres-db \
  plugin_name=postgresql-database-plugin \
  allowed_roles="app-role" \
  connection_url="postgresql://{{username}}:{{password}}@db.example.com:5432/mydb" \
  username="vaultadmin" \
  password="securepassword"

vault write database/roles/app-role \
  db_name=my-postgres-db \
  creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';" \
  default_ttl="1h" \
  max_ttl="24h"
```

When an application in Kubernetes logs in via the app-role, it receives a temporary user account in
the database.

**4. Vault Agent Sidecar Injector**

Access to secrets in the pods happens via the Vault Agent Injector. This is a mutating admission
webhook that automatically adds a sidecar to each pod with the correct annotations. This sidecar
authenticates itself with Vault and retrieves the correct secrets, which are then injected as a file
into the pod:

Access to secrets in the pods happens via the Vault Agent Injector. This is a mutating admission
webhook that automatically adds a sidecar to each pod with the correct annotations. This sidecar
authenticates itself with Vault and retrieves the correct secrets, which are then injected as a file
into the pod:

```yaml
annotations:
  vault.hashicorp.com/agent-inject: "true"
  vault.hashicorp.com/role: "myapp-role"
vault.hashicorp.com/agent-inject-secret-config.txt: "secret/myapp/config"
```

The sidecar also provides automatic lease renewal and support for dynamic secrets, such as temporary
database credentials. This ensures that credentials remain valid as long as the pod lives, without
manual intervention.

Alternatives that have been considered:

**Vault Secrets Operator (VSO)**

The Vault Secrets Operator uses Kubernetes Custom Resource Definitions (CRDs) to declaratively
manage secrets. This operator fetches secrets from Vault and creates native Kubernetes Secrets from
them, which can then be used by applications as usual.

**Vault CSI Provider**

The Vault CSI Provider uses the Kubernetes Secrets Store CSI Driver to dynamically mount secrets as
temporary files in pods.

Comparison:

| Feature                                | Vault Agent Injector         | Vault Secrets Operator | Vault CSI Provider     |
|----------------------------------------|------------------------------|------------------------|------------------------|
| **Secret delivery**                    | Sidecar volume               | Kubernetes Secret      | Ephemeral volume mount |
| **Dynamic secrets support**            | ✅ Yes                        | ❌ No (manual rotation) | ✅ Yes                  |
| **Lease management**                   | ✅ Automatic                  | ❌ No                   | ✅ Automatic            |
| **GitOps-compatibility**               | ⚠️ Limited (via annotations) | ✅ Full (via CRDs)      | ✅ Full (via CRDs)      |
| **Use of native K8s secrets**          | ❌ No                         | ✅ Yes                  | ❌ No                   |
| **Dependency on Vault at pod startup** | ✅ Yes                        | ❌ No                   | ✅ Yes                  |
| **Best application**                   | Dynamic credentials          | Static configuration   | File-based secrets     |

**5. Secure external access via internal NLB**

Vault is not publicly accessible. We have chosen to make Vault only available within our VPC via an
internal Network Load Balancer (NLB), which is linked to a Route 53 private DNS-entry
vault.tooling.internal. This way, services in the application cluster can still communicate with
Vault in the tooling cluster, without public endpoints or internet exposure.
The NLB is managed via a Kubernetes Service with the correct annotations for internal traffic:

```yaml
annotations:
  service.beta.kubernetes.io/aws-load-balancer-type: "external"
  service.beta.kubernetes.io/aws-load-balancer-scheme: "internal"
  service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "ip"
```

This ensures network security, availability and flexibility, while everything remains neatly within
the AWS-infrastructure.

### 7.6.11 HashiCorp Vault - Advantages

- **Strong security:** No storage of secrets in Kubernetes, automatic credential
- **Dynamic:** Database-credentials are temporary, automatically generated and cannot be reused.
- **Auditability:** Vault keeps a complete audit-log of all actions.
- **GitOps-integration:** Thanks to Helm and Flux, everything is declarative and manageable with
versions.
- **Cluster-wide access:** Thanks to the use of an internal NLB and DNS-abstraction, Vault is
reachable from any cluster within the VPC.

### 7.6.12 HashiCorp Vault - Vault agent flow

```mermaid
sequenceDiagram
box Pod: applicatie
participant Deployment
participant VaultAgent
end
Deployment ->> VaultAgent: Agent geïnjecteerd door agent-injector
participant VaultServer
VaultAgent ->> VaultServer: Auth via /auth/kubernetes/login met SA
VaultServer -->> VaultAgent: Vault token + policies
VaultAgent ->> VaultServer: Vraag secret op (bijv. db-creds)
VaultServer -->> VaultAgent: Secret value
VaultAgent ->> Deployment: Plaatst secret op bijv. /vault/secrets
```

**1. Injection of the Vault Agent:**
- An "Application Pod" is launched.
- The agent-injector (a Kubernetes admission controller) detects this pod and injects a Vault Agent
as a sidecar-container into the same pod. This means that the Vault Agent runs next to the
deployment container and has shared access to the pod's file system.

**2. Authentication of the Vault Agent:**
- The Vault Agent uses the ServiceAccount of the pod to authenticate with the Vault Server via the
path /auth/kubernetes/login.
- Vault uses the ServiceAccount identity of the pod and matches it with a predefined Vault role.
This role determines which policies and access rights the agent receives.

**3. Fetching secrets:**
- With the acquired Vault token, the "Pod: Vault Agent" requests a specific secret from the "Vault
Server" (for example "db-creds" for database references).
- The "Vault Server" returns the "Secret value" to the Vault Agent.

**5. Making secrets available to the application:**
- The "Pod: Vault Agent" places the received "Secret value" on a local, secured path within the pod,
for example "/vault/secrets/". This path is accessible to the application container (the "Pod:
Deployment").

This entire process serves a fundamental security goal: eliminating the need-to-know principle for
applications regarding secrets. Traditionally, secrets were often directly hardcoded in application
configurations, or set as environment variables in Kubernetes Deployments. Both methods are risky:

- **Hardcoded:** Sensitive information ends up in the source code or container-image, leading to
leaks when sharing code or images.

- **Environment variables/Kubernetes Secrets:** Although better, Kubernetes Secrets are by default
Base64-encoded and not truly encrypted in etcd. They can also be easily read by anyone with access
to the Kubernetes API. Moreover, managing the lifecycle of these secrets (rotation, revocation)
requires manual effort.

The advantages of the Vault Agent flow:

- No secrets in the application code: The application itself does not need to know about Vault,
implement a Vault SDK, or manage Vault tokens. The only thing the application sees is a local file
system containing the necessary secrets. This significantly reduces the attack surface.

- Strong authentication: By using the Kubernetes ServiceAccount authentication method, Vault can
cryptographically securely verify the identity of the requesting pod, without needing secret keys or
references to be stored in the pod itself.

- Automated secret rotation: The Vault Agent can be configured to periodically rotate secrets. When
a secret rotates in Vault, the agent automatically retrieves the new value and updates it on the
local path, without the application needing to be restarted.

- Audit Trail and Policies: All interactions between the Vault Agent and the Vault Server are logged
by Vault, which ensures a complete audit trail. Moreover, detailed policies can be applied in Vault,
so that each application only gets access to the specific secrets it needs.

- Centralization of secret management: Vault functions as the central, secure storage for all
secrets, which significantly simplifies the management, access, and lifecycle of secrets in a
complex microservices-architecture such as Kubernetes.

In short, the Vault Agent-flow offers a robust, secure, and automated way to provide applications in
Kubernetes access to secrets, by separating the complexity and risks of secret management from the
application itself and centralizing it in a specialized tool such as HashiCorp Vault.

### 7.6.13 HashiCorp Vault - Database engine flow

```mermaid
sequenceDiagram
participant Applicatie
participant Vault
participant Database
    
Applicatie ->> Vault: Vraag database-credentials aan (lease)
Vault ->> Database: Maak tijdelijke gebruiker aan met policy + TTL
Database -->> Vault: Bevestig aanmaak
Vault -->> Applicatie: Geeft tijdelijke username/password terug
Applicatie ->> Database: Verbind met tijdelijke credentials
```

**1. Request for database-credentials (lease):**
- An "Application" requests database-credentials from "Vault". The term "lease" emphasizes that
these credentials are temporary.

**2. Dynamic creation of user in the database:**
- "Vault" receives the request. Based on the configured rules in the Database Secrets Engine, Vault
instructs the "Database" to create a temporary user.
- Two crucial elements are provided with this creation:
- **Policy:** The rights this temporary user has within the database (for example only SELECT-rights
on specific tables).
- **TTL (Time To Live):** The lifespan of this temporary user. After this period, the user is
automatically revoked or deleted by Vault.
  
**3. Confirmation and return of credentials:**
- The "Database" confirms the creation of the temporary user to "Vault".
- "Vault" returns the temporary "username/password" combination to the "Application".

**4. Connect to the database:**
- The "Application" uses these just obtained temporary credentials to connect to the "Database".

---

## 7.7 External Secret Operator
  
### 7.7.1 External Secret Operator - What is the problem?

In a GitOps-architecture like that of FluxCD, all resources are declared in Git. This also means
that secrets (such as API-tokens, passwords or database credentials) cannot simply be put in Git as
plaintext — which would pose a serious security risk.

At the same time, Kubernetes workloads need access to these secrets, and we want to manage those
secrets in one central, secure place like HashiCorp Vault.
  
### 7.7.2 External Secret Operator - What is the solution?

The External Secrets Operator (ESO) functions as a bridge between external secret stores (like
Vault) and Kubernetes. ESO reads secrets from these external sources and converts them to Kubernetes
Secrets, so that applications can use them without ever being hardcoded in Git.

On top of that, FluxCD provides a declarative integration via secret substitution, allowing secrets
to still be added to your YAML-configurations — without storing the secrets themselves in Git.

Common components and their functions:

**1. Secret Providers:** These are the external systems where the secrets are actually stored.
 
- AWS Secrets: Refers to AWS Secrets Manager, Amazon Web Services' secret management service.
- Vault: Refers to HashiCorp Vault, a central system for managing secrets.

**2. ClusterSecretStores:** These are Kubernetes-objects (Custom Resources) that function as a
configuration for the External Secrets Operator. They define how the operator should authenticate
and communicate with a specific external Secret Provider at the cluster-level.

- AWSSecretStore: Configures the connection to AWS Secrets Manager (e.g. AWS region, authentication
method).
- VaultSecretStore: Configures the connection to HashiCorp Vault (e.g. Vault address, authentication
method).

```mermaid
flowchart TD
subgraph Secret Providers
AWSSecrets[AWS Secrets]
Vault
end

subgraph ClusterSecretStores
AWSSecretStore
VaultSecretStore
end
    
subgraph ExternalSecrets
AWSExternalSecret
VaultExternalSecret
end
    
subgraph Kubernetes Cluster 
K8sSecretAWS[K8s Secret - van AWS]
K8sSeccretVault[K8s Secret - van Vault]
FluxSubstitution[Flux Substitution]
end
    
AWSSecrets --> AWSSecretStore
Vault --> VaultSecretStore
AWSSecretStore --> AWSExternalSecret
VaultSecretStore --> VaultExternalSecret
AWSExternalSecret --> K8sSecretAWS
VaultExternalSecret --> K8sSeccretVault
K8sSecretAWS --> FluxSubstitution
K8sSeccretVault --> FluxSubstitution
```

**3. ExternalSecrets:** These are Kubernetes-objects (Custom Resources) that indicate which specific
secret from an external Secret Provider should be retrieved and how it should be represented in
Kubernetes. These are often installed per namespace or application.

- **AWSExternalSecret:** Specifies for example the name of a secret in AWS Secrets Manager and the
name of the Kubernetes Secret that should be created from this.

- **VaultExternalSecret:** Specifies for example the path to a secret in Vault and the name of the
Kubernetes Secret that should be created from this.

**4. Kubernetes Cluster:** This is the environment where the applications run.

- **k8s Secret - from AWS and k8s Secret - from Vault:** These are the standard Kubernetes
Secret-objects that are created and synchronized by the External Secrets Operator. They contain the
actual secret values that have been retrieved from the external providers. These Secrets can then be
mounted by Kubernetes-pods as files or environment variables.

**5. Flux Substitution:** This element, at the bottom of the diagram, indicates that further
processing can take place after the secrets have been placed as k8s Secret objects in the cluster.
Flux is a GitOps-tool that is often used for CI/CD in Kubernetes. "Substitution" suggests that
values from these Kubernetes Secrets can be used to, for example, fill placeholders in configuration
files, or to perform further transformations before they are used by applications. This is a common
pattern in GitOps-environments to keep the Secrets (which are dynamic) separate from the
application-configuration (which is often static in Git).

---

# 7. User scenario: external access to Vault

In modern cloud-native infrastructures, securing sensitive components such as a secret manager is
crucial. HashiCorp Vault forms the central secret management in our architecture and must under no
circumstances be publicly accessible. At the same time, both internal and external systems, such as
CI/CD pipelines, must be able to access Vault. The challenge is therefore: how do we make Vault
externally available, without publicly exposing it to the internet?

**The chosen solution: NLB + private DNS + VPN**

To solve this problem, we have chosen a combination of:
- An internal Network Load Balancer (NLB) in AWS to make Vault internally accessible
- A Route 53 Private Hosted Zone to provide a consistent, readable DNS name
- A VPN connection to allow external access without opening public ports.

This setup guarantees that all communication with Vault takes place within our private AWS-network,
without internet-exposure, but with controlled external access.

## 8.1 Network Load Balancer (NLB)

### 8.1.1 Network Load Balancer - What is it?

To make Vault accessible without public internet-exposure, a Kubernetes Service of type LoadBalancer
has been configured in the tooling cluster that is managed by AWS as an internal NLB. This service
automatically forwards all incoming TCP-traffic on port 8200 to the Vault-pods. Because we use the
annotation for an internal load balancer, the NLB does not get a public IP-address; instead, it is
exclusively available within the VPC. This keeps all Vault-traffic within the boundaries of our
AWS-network, which provides an extra layer of security and gives us full control over who may
connect.
An NLB can process very high volumes of TCP-traffic with minimal latency and maintains IP-source
information. Because Vault communicates over TCP on port 8200, the NLB is the most suitable
load-balancer in AWS for our use-case.

### 8.1.2 Network Load Balancer - How does it work?

The NLB listens on port 8200 and forwards all incoming connections to the Vault-pods. Because we use
the "internal" type, the load balancer does not get a public IP-address and is only accessible
within the VPC.

### 8.1.3 Network Load Balancer - Why was it chosen?

Vault uses TCP-traffic on port 8200, which requires a TCP-load balancer. An NLB is the best fitting
option within AWS for this traffic layer. Moreover, traffic remains completely within the
AWS-infrastructure, which significantly increases security.

### 8.1.4 Network Load Balancer - How was it implemented?

The NLB was automatically created via a Kubernetes service with specific AWS-annotations. By
combining the LoadBalancer type and the annotation
service.beta.kubernetes.io/aws-load-balancer-scheme: internal, an internal NLB is automatically
generated. For the selector annotation, we have given the name “Vault”, which ensures that it
automatically registers all Vault-pods in the target group.

### 8.1.5 Network Load Balancer - Advantages
- No public IP → safer
- Low latency, suitable for HA-applications
- Full control over subnet and VPC-choice

### 8.1.6 Network Load Balancer - Disadvantages
- Additional components to manage
- Potential costs with long-term use
- No layer 7-functionality such as URL-routing

## 8.2 Network Load Balancer - Target group and health check

The NLB has one listener on port 8200, linked to a target group that contains the individual
Vault-pod IP-addresses as backend. Through the Kubernetes-selector in the service configuration, all
active Vault-pods are automatically registered in this target group. For the health check of the
target group, we have set the standard Vault-endpoint `/v1/sys/health`. With this, we check not only
whether the pods are accessible, but also whether they actually function as a Vault-instance. Any
non-leader-nodes in an HA-setup give an HTTP 429-response, which we consider “healthy” to
exclude false positives.

## 8.3 Route 53 Private Hosted Zone

### 8.3.1 Route 53 Private Hosted Zone - What is it?

Although AWS automatically generates an NLB-DNS-name, this name is inconvenient and non-static. We
wanted a readable and consistent URL that works reliably within our VPC. Therefore, in Route 53, we
set up a Private Hosted Zone “tooling.internal”, linked to our VPC. Within this zone, a
CNAME-record “vault.tooling.internal” has been created, which refers to the internal DNS-name of
the NLB. In this way, we can systematically and unambiguously make a connection via a clear and
self-declared URL, while the underlying AWS-details remain hidden.

`vault.tooling.internal → vault-nlb-internal-xxxx.elb.eu-west-1.amazonaws.com`

### 8.3.1 Route 53 Private Hosted Zone - Why was it chosen?

- Consistency: in scripts, pipelines and policies, the same URL is always referred to.
- Readability: users do not have to remember complex hostnames.
- Flexibility: underlying load balancer can be changed without changes to the clients.

### 8.3.1 Route 53 Private Hosted Zone - How was it implemented?

In Route 53, the following configuration was created:


Zone: tooling.internal
Record: vault.tooling.internal → vault-nlb-internal-xxxx.elb.eu-west-1.amazonaws.com (CNAME)


This zone is linked to the VPC-ID of the tooling cluster AND the application cluster via
VPC-peering.

### 8.3.2 Route 53 Private Hosted Zone - Advantages

- **Security:** Vault remains completely within our VPC, so we do not have to maintain public
security-groups or internet-ACLs.
- **Automation:** Kubernetes regulates registration of Vault-pods in the target group.
- **Ease of use:** clear DNS-name improves readability and reduces the chance of errors.

### 8.3.3 Route 53 Private Hosted Zone - Disadvantages

- **Complexity:** extra components (NLB, target group, DNS-zone) require active management and
monitoring.
- **Costs:** NLB-hours and Route 53-queries are not free. This must be taken into account in a cost
analysis.
- **Failover and scale:** health checks must be correctly configured for HA-setups, and subnets must
be selected in multiple zones.

## 8.4 VPN

### 8.4.1 VPN - What is it?

An AWS Client VPN-endpoint was deployed via Terraform as a secured gateway to the private network in
which Vault runs. Only authenticated users with a valid client certificate, signed by our own Root
CA, can connect and reach Vault via private DNS (e.g. vault.service.internal).

### 8.4.2 VPN - Why was it chosen?

- No public exposure of Vault: Vault is only accessible within the private network via the VPN.
- Manageable access: Each user receives a unique, self-signed client certificate, which is easy to
manage, revoke and audit.
- Automatable & integratable: Both the infrastructure and the generation of the certificate are
automated with Terraform and a simple script.

### 8.4.3 VPN - How was it implemented?

**Infrastructure with Terraform**

- A TLS Root CA is generated with the tls provider in Terraform.
- The VPN-server receives a certificate that is signed by the Root CA.
- Both certificates are imported into AWS Certificate Manager (ACM).
- An AWS Client VPN Endpoint is configured with:
- Certificate-authentication
- Private subnet associations
- Rules that allow traffic to the internal VPC-network where Vault runs.

**Generate Client Certificates**

Client certificates are not managed manually, but automatically generated via a script:
`./generate-client.sh`

The script does the following:
1. Reads the Root CA from Terraform outputs
2. Generates a new client private key & CSR
3. Signs the CSR with the Root CA
4. Builds an .ovpn-file with embedded certificates:
- `<ca>...</ca>` → Root CA
- `<cert>...</cert>` → Client Cert
- `<key>...</key>` → Client Key

Connect to the VPN

After generating the configuration file: `sudo openvpn --config client-config.ovpn`

Vault is then accessible on the private network via the DNS-name (e.g. https://vault.internal:8200).

# 9. Installation Guide

The full infrastructure of this project can be deployed with a minimum of manual intervention thanks
to a combination of Terraform and FluxCD. Below is a structured guide that describes how a user can
correctly deploy the infrastructure, clusters and applications.

## 9.1 Requirements

Before you start, make sure the following tools and configurations are available on your local
machine:

- **AWS CLI**, correctly configured (via AWS-profile or IAM-credentials)
- **Terraform** (≥ version 1.4)
- **kubectl** (to communicate with Kubernetes)
- **Flux CLI** (for GitOps management)
- **Access to an AWS-account** with rights to:
- Create EKS-clusters, VPCs, IAM-roles, Load Balancers and VPNs
- **A Git repository** with GitOps-configuration (e.g. fork of our original repo)

## 9.2 Cloning the infrastructure repository

Start by fetching the repository on GitLab:

```shell
git clone <>
cd /infra
```

## 9.3 Terraform initialization

Terraform is used to set up the entire AWS-environment. Start by initializing Terraform:

```shell
terraform init
terraform plan
terraform apply
```

This first apply will create the following components:
- VPCs and subnets
- IAM-roles and policies
- EKS-clusters (application cluster and tooling cluster)

- Basic configuration for Kubernetes (such as kubeconfig outputs)

## 9.4 GitOps-automation via FluxCD
Once the infrastructure is up and the Load Balancer Controller is active, you can execute the
remaining modules of Terraform. In the main.tf file these are initially commented out in the module
K8s.

- Uncomment the blocks that refer to:
- Kubernetes-modules
- Flux-bootstrap
- VPN-configuration

Then execute `terraform apply` again. Flux will now automatically:
- Synchronize the GitOps-repo
- Install Helm charts (Vault, Istio, GitLab Runner)
- Deploy microservices
- Create policies, serviceaccounts and namespaces

## 9.5 Vault recovery on first bootstrap

If the Vault bootstrap crashes during the first synchronization:

1. Delete the incorrect Kustomization and associated secret:

```shell
kubectl delete kustomization vault-bootstrap -n flux-system
kubectl delete secret vault-bootstrap-secret -n flux-system
```

2. Force a new reconcile:

```shell
flux reconcile kustomization vault-bootstrap --with-source
```

Vault will now be set up correctly.

## 9.6 GitLab-runner setup

For the correct functioning of CI/CD, a valid GitLab Runner token is needed.

1. Create a runner in GitLab and copy the registration-token.
2. Add the token to Vault:
```shell
vault kv put kv/gitlab/runner registrationToken=<your_token>
```
3. Ensure that the Vault policy and the ExternalSecret are correctly set up so that Flux can fetch
the token and inject it into the runner-installation.

## 9.7 VPN Configuration (for external access to Vault)
In the “infrastructure” repository go to the vpn folder, run the `./generate-config.sh`
script. 
And connect via the command: 

```shell
sudo openvpn –config client-config.ovpn`
```

## 9.8 Overview of the Deployment Flow

The deployment follows these structured steps:
1. **Terraform apply (infra layer):** creates networks, IAM, EKS.
2. **Terraform apply (Kubernetes-modules + Flux):** sets up all cluster configuration.
3. **Flux bootstraps automatically:** Istio, Vault, GitLab Runner, microservices, policies.
4. **CI/CD** is manually configured where needed (gitlab registration token).
5. **VPN** Configuration via script

## 9.9 Result

After executing these steps, a fully functional, secure, and modular Kubernetes-architecture in AWS
is in place with:
- Integrated GitOps-pipeline (Flux)
- Automatic CI/CD via GitLab Runner + Podman
- Secure secret management with Vault
- Internal access via VPN + Private DNS
- And a service mesh for microservices traffic

- If desired, this process can be easily replicated to other regions by creating a new variable set
and workspace in Terraform.

# 10. Technical conclusion

This implementation demonstrates a complete, production-ready approach to secret management in modern cloud infrastructures. The combination of HashiCorp Vault, Kubernetes, and GitOps principles results in a robust architecture that meets enterprise security requirements.

Key technical achievements:
- Zero-downtime secret rotation via dynamic credentials
- Full infrastructure-as-code with reproducible deployments
- Automated security policies via service mesh
- Scalable multi-cluster architecture with clear separation of concerns

The documented approach provides teams with a proven path to:
- Improved security posture through elimination of static credentials
- Increased operational efficiency via automation
- Compliance-ready infrastructure with complete audit trails
- Disaster recovery capabilities via GitOps

This architecture is production-ready and scalable for organizations of various sizes, with the flexibility to adapt to specific requirements without compromising core security principles.

63
