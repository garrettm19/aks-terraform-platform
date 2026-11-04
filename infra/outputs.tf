# ================================
# AKS Terraform Platform - Outputs
# ================================
# Purpose: Export values for CI/CD pipelines and kubectl configuration
# Usage: terraform output <output_name>

# ================================
# Resource Group Outputs
# ================================

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Azure region where resources are deployed"
  value       = azurerm_resource_group.main.location
}

# ================================
# AKS Cluster Outputs
# ================================

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_cluster_id" {
  description = "AKS cluster resource ID"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "aks_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "aks_node_resource_group" {
  description = "Auto-generated resource group for AKS nodes"
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "aks_kubernetes_version" {
  description = "Kubernetes version running on AKS"
  value       = azurerm_kubernetes_cluster.aks.kubernetes_version
}

# ================================
# ACR Outputs
# ================================

output "acr_name" {
  description = "Name of the Azure Container Registry"
  value       = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  description = "Login server URL for ACR (use for docker push)"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "ACR admin username (for CI/CD)"
  value       = azurerm_container_registry.acr.admin_username
  sensitive   = true
}

output "acr_admin_password" {
  description = "ACR admin password (for CI/CD)"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}

# ================================
# Key Vault Outputs
# ================================

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "key_vault_id" {
  description = "Resource ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

# ================================
# Monitoring Outputs
# ================================

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = var.enable_monitoring ? azurerm_log_analytics_workspace.main[0].id : null
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = var.enable_monitoring ? azurerm_log_analytics_workspace.main[0].name : null
}

# ================================
# Kubectl Configuration Command
# ================================

output "configure_kubectl_command" {
  description = "Command to configure kubectl to connect to AKS"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.aks.name} --overwrite-existing"
}

# ================================
# ACR Docker Login Command
# ================================

output "acr_docker_login_command" {
  description = "Command to login to ACR with Docker"
  value       = "az acr login --name ${azurerm_container_registry.acr.name}"
}

# ================================
# Quick Start Commands
# ================================

output "quick_start_guide" {
  description = "Quick start commands for using the infrastructure"
  value       = <<-EOT
  
  ═══════════════════════════════════════════════════════════
  AKS Terraform Platform - Quick Start Guide
  ═══════════════════════════════════════════════════════════
  
  1. Configure kubectl:
     ${format("az aks get-credentials --resource-group %s --name %s", azurerm_resource_group.main.name, azurerm_kubernetes_cluster.aks.name)}
  
  2. Verify cluster access:
     kubectl get nodes
     kubectl get namespaces
  
  3. Login to ACR:
     az acr login --name ${azurerm_container_registry.acr.name}
  
  4. Tag and push Docker image:
     docker tag api:v1 ${azurerm_container_registry.acr.login_server}/api:v1
     docker push ${azurerm_container_registry.acr.login_server}/api:v1
  
  5. View Key Vault secrets:
     az keyvault secret list --vault-name ${azurerm_key_vault.main.name}
  
  6. Access Azure Portal:
     Resource Group: ${azurerm_resource_group.main.name}
     Region: ${azurerm_resource_group.main.location}
  
  ═══════════════════════════════════════════════════════════
  EOT
}

# ================================
# Cost Estimation
# ================================

output "estimated_monthly_cost" {
  description = "Rough monthly cost estimate (USD)"
  value       = <<-EOT
  
  Estimated Monthly Costs (approximate):
  - AKS cluster (2 x Standard_DS2_v2): ~$140-160/month
  - Azure Container Registry (Basic): ~$5/month
  - Key Vault: ~$1-2/month
  - Log Analytics: ~$50-80/month (varies by usage)
  - Load Balancer: ~$20-30/month
  ────────────────────────────────────────────
  Total: ~$220-280/month
  
  Daily cost: ~$7-10/day
  
  To minimize costs, destroy the infrastructure when not in use:
     Command: terraform destroy
  EOT
}

# ================================
# Security Reminders
# ================================

output "security_notes" {
  description = "Important security considerations"
  value       = <<-EOT
  
  Security checklist:
  - RBAC enabled on AKS
  - AKS connected to ACR via managed identity
  - Key Vault access policies configured
  - Admin credentials enabled for ACR (disable for production)
  
  For production:
  - Enable private cluster endpoint
  - Disable ACR admin account, use service principals
  - Enable Key Vault purge protection
  - Implement network policies
  - Enable Azure Policy for compliance
  - Configure TLS/SSL certificates
  EOT
}