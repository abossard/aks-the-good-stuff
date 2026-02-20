# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.23.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.6.3"
    }
  }
}

resource "random_string" "rand" {
  length = 4
  special = false
  lower = true
  upper = false
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
     resource_group {
       prevent_deletion_if_contains_resources = false
     }
   }
}

data "azurerm_client_config" "current" {}

# References existing resource group
resource "azurerm_resource_group" "rg" {
  name = var.resource-group-name
  location = var.location
}

# Creates and configures a storage account 
resource "azurerm_storage_account" "storage" {
  name                      = "storage${random_string.rand.result}"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.rg.name
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  access_tier               = "Hot"
  https_traffic_only_enabled = true
}

# Creates the Azure Container Registry to be used with AKS
resource "azurerm_container_registry" "acr" {
  name                = "acr${random_string.rand.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  admin_enabled       = false
}

# Creates the base AKS Cluster with Azure CNI overlay for the networking model
resource "azurerm_kubernetes_cluster" "aks" {

  name                 = "aks${random_string.rand.result}"
  location             = var.location
  resource_group_name  = azurerm_resource_group.rg.name
  dns_prefix           = "aks${random_string.rand.result}"
  azure_policy_enabled = true
  oidc_issuer_enabled = true

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }
  
  default_node_pool {
    name                = "systempool"
    node_count          = 1
    auto_scaling_enabled = true
    min_count           = 1
    max_count           = 3
    vm_size             = "Standard_D2as_v5"
    zones               = ["1"]
    node_labels = {
      "node.kubernetes.io/system-nodes" = "true"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    network_plugin_mode = "overlay"
    network_data_plane = "cilium"
    network_policy = "cilium"
  }

  auto_scaler_profile {
    scale_down_unneeded         = "1m"
    scale_down_delay_after_add  = "1m"
    scale_down_unready          = "1m"
    skip_nodes_with_system_pods = true
  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
    ]
  }
}

# Gives the AKS Cluster ACR pull role over the AKS Cluster
resource "azurerm_role_assignment" "aks_acr" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

resource "azurerm_key_vault" "kv" {
  name                       = "kv-${random_string.rand.result}"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  public_network_access_enabled = true
  purge_protection_enabled = false
  enable_rbac_authorization = true
}

resource "azurerm_key_vault_secret" "secret" {
  name         = "mysecret"
  value        = "mySuperSecretValue"
  key_vault_id = azurerm_key_vault.kv.id
  depends_on = [ 
    azurerm_role_assignment.current_user_kv_secrets_officer 
  ]
}

resource "azurerm_role_assignment" "current_user_kv_secrets_officer" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

