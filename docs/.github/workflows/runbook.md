# EVAAS DevOps Simulation - Runbook

## Prerequisites
- Azure CLI installed and logged in
- Terraform >= 1.0
- Docker Desktop
- kubectl
- Python 3.10+

## Initial Setup

### 1. Clone Repository
git clone <your-repo-url>
cd evaas-sim

### 2. Provision Infrastructure
cd infra
terraform init
terraform plan
terraform apply

### 3. Configure kubectl
az aks get-credentials --resource-group evaas-dev-rg --name evaas-dev-aks
kubectl get nodes

### 4. Login to ACR
az acr login --name evaasdevacr

## Build and Deploy Application

### 1. Build Docker Image
cd app
docker build -t evaas-app:v1 .

### 2. Tag and Push to ACR
docker tag evaas-app:v1 evaasdevacr.azurecr.io/evaas-app:v1
docker push evaasdevacr.azurecr.io/evaas-app:v1

### 3. Deploy to AKS
cd ../k8s
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

### 4. Verify Deployment
kubectl get pods
kubectl get services
kubectl logs <pod-name>

