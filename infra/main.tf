# ================================
# AKS Terraform Platform - Main Infrastructure
# ================================
# Purpose: Provision Azure resources for containerized application
# Architecture: AKS + ACR + Key Vault + Monitoring

# ================================
# Terraform Configuration
# ================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# ================================
# Provider Configuration
# ================================

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# ================================
# Data Sources
# ================================

# Get current Azure client configuration
data "azurerm_client_config" "current" {}

# ================================
# Resource Group
# ================================

resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-${var.environment}-rg"
  location = var.location
  tags     = var.tags
}

# ================================
# Log Analytics Workspace (for monitoring)
# ================================

resource "azurerm_log_analytics_workspace" "main" {
  count = var.enable_monitoring ? 1 : 0

  name                = "${var.project_name}-${var.environment}-logs"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_analytics_retention_days
  tags                = var.tags
}

# ================================
# Azure Container Registry (ACR)
# ================================

resource "azurerm_container_registry" "acr" {
  name                = "${var.project_name}${var.environment}acr" # Must be globally unique, no hyphens
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = var.acr_sku
  admin_enabled       = var.acr_admin_enabled

  tags = merge(
    var.tags,
    {
      Purpose = "Container image storage"
    }
  )
}

# ================================
# Azure Kubernetes Service (AKS)
# ================================

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.project_name}-${var.environment}-aks"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.project_name}-${var.environment}"
  kubernetes_version  = var.kubernetes_version
  support_plan        = "KubernetesOfficial"


  # Node pool configuration
  default_node_pool {
    name                = "default"
    node_count          = var.enable_auto_scaling ? null : var.node_count
    vm_size             = var.node_vm_size
    enable_auto_scaling = var.enable_auto_scaling
    min_count           = var.enable_auto_scaling ? var.min_node_count : null
    max_count           = var.enable_auto_scaling ? var.max_node_count : null
    os_disk_size_gb     = 30
    type                = "VirtualMachineScaleSets"

    # Network configuration
    vnet_subnet_id = null # Using kubenet, not Azure CNI
  }

  # Identity for AKS to access Azure resources
  identity {
    type = "SystemAssigned"
  }

  # Network profile
  network_profile {
    network_plugin    = var.network_plugin
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  # RBAC and Azure AD integration
  role_based_access_control_enabled = var.enable_rbac

  # Monitoring integration
  dynamic "oms_agent" {
    for_each = var.enable_monitoring ? [1] : []
    content {
      log_analytics_workspace_id = azurerm_log_analytics_workspace.main[0].id
    }
  }

  # Add-ons
  http_application_routing_enabled = false # Not recommended for production

  tags = merge(
    var.tags,
    {
      Purpose = "Kubernetes cluster for application workloads"
    }
  )

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count # Allow manual scaling
    ]
  }
}

# ================================
# Connect AKS to ACR (allow image pull)
# ================================

resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

# ================================
# Key Vault (for secrets management)
# ================================

# Generate unique suffix for Key Vault name (must be globally unique)
resource "random_string" "kv_suffix" {
  length  = 4
  special = false
  upper   = false
  numeric = true
}

resource "azurerm_key_vault" "main" {
  name                        = "${var.project_name}-${var.environment}-kv-${random_string.kv_suffix.result}"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = var.soft_delete_retention_days
  purge_protection_enabled    = false # Enable for production workloads
  sku_name                    = var.key_vault_sku

  # Access policy for current user (you)
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "List", "Create", "Delete", "Update", "Purge"
    ]

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge", "Recover"
    ]

    certificate_permissions = [
      "Get", "List", "Create", "Delete", "Update", "Purge"
    ]
  }

  # Access policy for AKS to read secrets
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id

    secret_permissions = [
      "Get", "List"
    ]
  }

  tags = merge(
    var.tags,
    {
      Purpose = "Secrets management"
    }
  )
}

# ================================
# Sample Secret
# ================================

# Generated at apply time so no secret value is stored in source control.
# Note: the value is still kept in Terraform state; protect the state file.
resource "random_password" "demo_db_password" {
  length           = 24
  special          = true
  override_special = "!#%*-_=+"
}

resource "azurerm_key_vault_secret" "demo_secret" {
  name         = "demo-database-password"
  value        = random_password.demo_db_password.result
  key_vault_id = azurerm_key_vault.main.id

  tags = {
    Purpose = "Sample secret showing Key Vault usage"
  }

  depends_on = [
    azurerm_key_vault.main
  ]
}

# ================================
# Network Security Group
# ================================

resource "azurerm_network_security_group" "aks" {
  name                = "${var.project_name}-${var.environment}-aks-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Allow HTTPS inbound (for ingress controller)
  security_rule {
    name                       = "allow-https"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow HTTP inbound (consider restricting once TLS is in place)
  security_rule {
    name                       = "allow-http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# ================================
# Resource Tags Summary
# ================================

# All resources inherit tags from variables
# Additional tags added per resource for specific purposes