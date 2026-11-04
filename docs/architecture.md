# EVAAS DevOps Simulation - Architecture

## Overview
This project simulates the SAS EVAAS DevOps workflow with a cloud-native architecture on Azure.

## Architecture DiagramGitHub Repository
↓
GitHub Actions (CI/CD)
↓
Docker Build → Trivy Security Scan
↓
Azure Container Registry (ACR)
↓
Azure Kubernetes Service (AKS)
↓ (monitoring)
Prometheus + Grafana

## Infrastructure Components

### Azure Resources
- **Resource Group**: `evaas-dev-rg` (Central US)
- **AKS Cluster**: `evaas-dev-aks`
  - Kubernetes version: 1.31
  - Node pool: 1 x Standard_B2s (2 vCPU, 4GB RAM)
  - Network plugin: kubenet
  - RBAC: Enabled
- **Container Registry**: `evaasdevacr` (Basic SKU)
- **Key Vault**: Secrets management
- **Log Analytics**: Monitoring and observability

### Application
- **Framework**: FastAPI (Python 3.10)
- **Server**: Uvicorn ASGI
- **Containerization**: Docker
- **Endpoint**: `/predict` - Analytics prediction API

## Security Measures
- Kubernetes RBAC enabled
- Key Vault for secret management
- ACR integrated with AKS via managed identity
- Image scanning with Trivy
- Network security groups

## Cost Optimization
- Single-node cluster for demo ($3-4/day)
- Standard_B2s burstable instances
- Basic tier ACR
- 30-day log retention

## Deployment Flow
1. Developer commits code to GitHub
2. GitHub Actions triggers CI/CD pipeline
3. Docker image built and scanned
4. Image pushed to ACR
5. Kubernetes deployment updated
6. Health checks verify deployment
7. Metrics collected by Prometheus