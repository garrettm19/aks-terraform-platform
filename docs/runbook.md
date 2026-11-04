# Runbook

## Prerequisites

- Azure CLI, logged in (`az login`)
- Terraform >= 1.0
- Docker
- kubectl
- Python 3.12 (for running the app and tests locally)

`scripts/install-tools.sh` installs Terraform, kubectl and the Azure CLI on
Debian/Ubuntu.

## 1. Clone the repository

```bash
git clone <your-repo-url> aks-terraform-platform
cd aks-terraform-platform
```

## 2. Provision infrastructure

```bash
cd infra
terraform init
terraform plan
terraform apply
```

The commands below assume the default `project_name` (`aksplatform`) and
`environment` (`dev`). If you changed them, use the values from
`terraform output`.

## 3. Configure kubectl

```bash
az aks get-credentials --resource-group aksplatform-dev-rg --name aksplatform-dev-aks
kubectl get nodes
```

## 4. Log in to ACR

```bash
az acr login --name aksplatformdevacr
```

## Build and deploy the application

### 1. Build the Docker image

```bash
cd ../app
docker build -t api:v1 .
```

### 2. Tag and push to ACR

```bash
docker tag api:v1 aksplatformdevacr.azurecr.io/api:v1
docker push aksplatformdevacr.azurecr.io/api:v1
```

If your ACR name differs, update the `image:` field in `k8s/deployment.yaml`
to match.

### 3. Deploy to AKS

```bash
cd ../k8s
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

### 4. Verify the deployment

```bash
kubectl get pods
kubectl get service api-service    # wait for EXTERNAL-IP
kubectl logs deployment/api
curl http://<EXTERNAL-IP>/health
curl "http://<EXTERNAL-IP>/predict?score=100"
```

## Clean up

```bash
kubectl delete -f k8s/
cd infra
terraform destroy
```
