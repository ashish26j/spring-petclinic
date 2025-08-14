terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.9" // 3.9.0+ required for synapse workspace bugfix
    }

    azuread = { // Azure Active Directory
      source  = "hashicorp/azuread"
      version = "~> 3.1.0"
    }

    azurestack = { // Azure Stack
      source  = "hashicorp/azurestack"
      version = ">= 0.10.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group ? 1 : 0
  location = var.location
  name     = var.resource_group_name
}

provider "azuread" {}

provider "azurestack" {
  features {}
  subscription_id = var.subscription_id
}
