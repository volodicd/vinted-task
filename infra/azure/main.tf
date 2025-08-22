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
    key                 = "okta-dev.terraform.tfstate"
  }
}




data "azurerm_resource_group" "rg_group" {
  name = "tryout-RG"
}

resource "azurerm_container_registry" "test_registry" {
  location            = data.azurerm_resource_group.rg_group.location
  name                = "oktatestacr"
  resource_group_name = data.azurerm_resource_group.rg_group.name
  sku                 = "Basic"
  admin_enabled = true
}

resource "azurerm_log_analytics_workspace" "test_workspace" {
  location            = data.azurerm_resource_group.rg_group.location
  name                = "okta-test-los"
  resource_group_name = data.azurerm_resource_group.rg_group.name
  retention_in_days = 30
}

resource "azurerm_container_app_environment" "test_environment" {
  location            = data.azurerm_resource_group.rg_group.location
  name                = "okta-test-env"
  resource_group_name = data.azurerm_resource_group.rg_group.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test_workspace.id
}


resource "azurerm_container_app" "test_container_app" {
  name                = "okta-test-app"
  resource_group_name = data.azurerm_resource_group.rg_group.name
  container_app_environment_id = azurerm_container_app_environment.test_environment.id
  revision_mode = "Single"

  registry {
    server   = azurerm_container_registry.test_registry.login_server
    username = azurerm_container_registry.test_registry.admin_username
    password_secret_name = "registry-password"
  }


   template {


    container {
      name   = "okta-test"
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
        value = "https://okta-test-app.${azurerm_container_app_environment.test_environment.default_domain}/auth/callback"
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
    value = azurerm_container_registry.test_registry.admin_password
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