# ================================
# EVAAS DevOps Simulation - Variables
# ================================
# Purpose: Define configurable parameters for infrastructure
# Design: Enterprise-grade with validation and documentation

# ================================
# Project Configuration
# ================================

variable "project_name" {
  description = "Project identifier used for resource naming (lowercase, no special chars)"
  type        = string
  default     = "evaas"

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters and numbers (Azure naming requirements)."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# ================================
# Azure Region Configuration
# ================================

variable "location" {
  description = "Azure region for all resources (cost optimization: East US is typically cheapest)"
  type        = string
  default     = "Central US"
}

# ================================
# AKS Cluster Configuration
# ================================

variable "kubernetes_version" {
  description = "Kubernetes version for AKS cluster (use latest stable for security patches)"
  type        = string
  default     = "1.31" # Latest stable as of Oct 2024
}

variable "node_count" {
  description = "Initial number of nodes in default node pool (2-3 for HA, 1 for cost savings)"
  type        = number
  default     = 1

  validation {
    condition     = var.node_count >= 1 && var.node_count <= 10
    error_message = "Node count must be between 1 and 10."
  }
}

variable "node_vm_size" {
  description = "VM size for AKS nodes (Standard_DS2_v2 = 2vCPU, 7GB RAM - good for demos)"
  type        = string
  default     = "Standard_B2s"
}

variable "enable_auto_scaling" {
  description = "Enable cluster autoscaler (production best practice)"
  type        = bool
  default     = false # Start disabled for cost control, enable for interview demo
}

variable "min_node_count" {
  description = "Minimum nodes when autoscaling enabled"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum nodes when autoscaling enabled"
  type        = number
  default     = 5
}

# ================================
# Container Registry Configuration
# ================================

variable "acr_sku" {
  description = "ACR SKU tier (Basic for dev, Standard for staging, Premium for prod with geo-replication)"
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "ACR SKU must be Basic, Standard, or Premium."
  }
}

variable "acr_admin_enabled" {
  description = "Enable admin user for ACR (needed for CI/CD, disable in prod with service principals)"
  type        = bool
  default     = true
}

# ================================
# Security Configuration
# ================================

variable "enable_rbac" {
  description = "Enable Kubernetes RBAC (always true for security)"
  type        = bool
  default     = true
}

variable "enable_private_cluster" {
  description = "Make AKS API server private (production best practice, costs more)"
  type        = bool
  default     = false # Public for demo, private for production
}

variable "network_plugin" {
  description = "Kubernetes network plugin (azure for Azure CNI, kubenet for basic networking)"
  type        = string
  default     = "kubenet" # kubenet = simpler + cheaper, azure = advanced features

  validation {
    condition     = contains(["azure", "kubenet"], var.network_plugin)
    error_message = "Network plugin must be azure or kubenet."
  }
}

# ================================
# Key Vault Configuration
# ================================

variable "key_vault_sku" {
  description = "Key Vault SKU (standard or premium with HSM support)"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku)
    error_message = "Key Vault SKU must be standard or premium."
  }
}

variable "enable_soft_delete" {
  description = "Enable soft delete for Key Vault (prevents accidental secret deletion)"
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "Days to retain soft-deleted secrets (7-90)"
  type        = number
  default     = 7

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Retention days must be between 7 and 90."
  }
}

# ================================
# Monitoring Configuration
# ================================

variable "enable_monitoring" {
  description = "Enable Azure Monitor and Container Insights (production must-have)"
  type        = bool
  default     = true
}

variable "log_analytics_retention_days" {
  description = "Days to retain logs in Log Analytics (30-730)"
  type        = number
  default     = 30

  validation {
    condition     = var.log_analytics_retention_days >= 30 && var.log_analytics_retention_days <= 730
    error_message = "Retention must be between 30 and 730 days."
  }
}

# ================================
# Tagging Strategy
# ================================

variable "tags" {
  description = "Common tags applied to all resources (for cost tracking and organization)"
  type        = map(string)
  default = {
    Project     = "EVAAS-Simulation"
    ManagedBy   = "Terraform"
    Environment = "Development"
    Owner       = "DevOps-Team"
    CostCenter  = "Engineering"
  }
}

# ================================
# Cost Optimization Flags
# ================================

variable "enable_cost_savings" {
  description = "Enable cost-saving measures (smaller VMs, no redundancy - for demo only)"
  type        = bool
  default     = true # Safe for portfolio project
}

# ================================
# Interview Demo Features
# ================================

variable "enable_demo_features" {
  description = "Enable features useful for demonstrating capabilities (sample workloads, dashboards)"
  type        = bool
  default     = true
}