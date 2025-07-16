# App GitOps

A simple GitOps repository for your application.

## Overview
- **app/istio**: Istio configuration  
- **app/manifests/**: Kubernetes YAMLs for all services  
- **app/namespaces/**: Namespace definitions  
- **app-cluster/**: Kustomize configuration and Flux bootstrap  
- **app-cluster/flux-system/**: Flux components (in `app-cluster/flux-system`)

## Requirements
- git  
- kubectl (v1.20+)  
- kustomize  
- [Flux CLI](https://fluxcd.io/docs/cli/)

## Installation & Deployment
1. Clone the repo  

2. Bootstrap Flux (GitHub/GitLab)
  
``` 
cd clusters

flux bootstrap gitlab \
  --owner=<group> \
  --repository=<repo-name> \
  --path=./app-cluster
```
