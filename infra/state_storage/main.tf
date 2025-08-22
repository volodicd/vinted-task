# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.85"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "rg_group" {
  name = "tryout-RG"
}

resource "azurerm_storage_account" "terraform_state" {
  name                     = "tfstatevinted434"
  resource_group_name      = data.azurerm_resource_group.rg_group.name
  location                = data.azurerm_resource_group.rg_group.location
  account_tier            = "Standard"
  account_replication_type = "LRS"


  min_tls_version                = "TLS1_2"
  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "state" {
  name = "tfstate"
  storage_account_name = azurerm_storage_account.terraform_state.name
  container_access_type = "private"
}

output "resource_group_name" {
  description = "Resource group name for backend config"
  value       = data.azurerm_resource_group.rg_group.name
}

output "storage_account_name" {
  description = "Storage account name for backend config"
  value       = azurerm_storage_account.terraform_state.name
}

output "container_name" {
  description = "Container name for backend config"
  value       = azurerm_storage_container.state.name
}

output "backend_config" {
  description = "backend config"
  value = <<-EOT
terraform {
  backend "azurerm" {
    resource_group_name  = "${data.azurerm_resource_group.rg_group.name}"
    storage_account_name = "${azurerm_storage_account.terraform_state.name}"
    container_name      = "${azurerm_storage_container.state.name}"
    key                 = "your-project.terraform.tfstate"
  }
}
EOT
}