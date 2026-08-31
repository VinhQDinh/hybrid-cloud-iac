terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 3.100.0"
    }
  }
  
  backend "azurerm" {
    resource_group_name = "rg-terraform-state-mgmt"
    storage_account_name = "sttfstatehybrid20c19b"
    container_name = "tfstate-hybrid-enterprise"
    key = "hybrid-core.tfstate"
    use_azuread_auth = true 
  }
  
}

