terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.85"
    }
  }
}


provider "azurerm" {
  features {}
}


data "terraform_remote_state" "okta" {
  backend = "azurerm"
  config = {
    resource_group_name  = "tryout-RG"
    storage_account_name = "tfstatevinted434"
    container_name      = "tfstate"
    key                 = "okta.terraform.tfstate"
  }
}


data "azurerm_resource_group" "rg_group" {
  name = "tryout-RG"
}

resource "azurerm_container_registry" "main" {
  location            = data.azurerm_resource_group.rg_group.location
  name                = var.container_reg_name
  resource_group_name = data.azurerm_resource_group.rg_group.name
  sku                 = "Basic"
  admin_enabled = true
}

resource "azurerm_log_analytics_workspace" "main" {
  location            = data.azurerm_resource_group.rg_group.location
  name                = "${var.container_reg_name}-log"
  resource_group_name = data.azurerm_resource_group.rg_group.name
  retention_in_days = 30
}

resource "azurerm_container_app_environment" "main" {
  location            = data.azurerm_resource_group.rg_group.location
  name                = "${var.container_reg_name}-env"
  resource_group_name = data.azurerm_resource_group.rg_group.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
}


resource "azurerm_container_app" "test_container_app" {
  name                = "${var.container_reg_name}-app"
  resource_group_name = data.azurerm_resource_group.rg_group.name
  container_app_environment_id = azurerm_container_app_environment.main.id
  revision_mode = "Single"

  registry {
    server   = azurerm_container_registry.main.login_server
    username = azurerm_container_registry.main.admin_username
    password_secret_name = "registry-password"
  }
   template {
    container {
      name   = var.container_name
      image = "oktatestacr.azurecr.io/oidc-flask:latest"

      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "OKTA_ISSUER"
        value = data.terraform_remote_state.okta.outputs.issuer
      }
      env {
        name  = "OKTA_CLIENT_ID"
        value = data.terraform_remote_state.okta.outputs.client_id
      }
      env {
        name        = "OKTA_CLIENT_SECRET"
        secret_name = "okta-secret"
      }
      env {
        name  = "REDIRECT_URI"
        value = "https://${var.container_reg_name}-app.${azurerm_container_app_environment.main.default_domain}/auth/callback"
      }
      env {
        name  = "SECRET_KEY"
        value = "simple-test-secret"
      }
    }
  }

  secret {
    name  = "okta-secret"
    value = data.terraform_remote_state.okta.outputs.client_secret
  }
    secret {
    name  = "registry-password"
    value = azurerm_container_registry.main.admin_password
  }

  ingress {
    external_enabled = true
    target_port     = 8080
    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }
}