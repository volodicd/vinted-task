terraform {
  backend "azurerm" {
    resource_group_name  = "tryout-RG"
    storage_account_name = "tfstatevinted434"
    container_name      = "tfstate"
    key = "azure-dev.terraform.tfstate"
  }
}