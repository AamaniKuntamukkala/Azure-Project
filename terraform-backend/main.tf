# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "azurerm" {
  features {}
}

# Create a Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create a Storage Account required by the Function App
resource "azurerm_storage_account" "storage" {
  name                     = "${var.project_prefix}storage"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create an F1 (Free) App Service Plan that complies with policy
resource "azurerm_service_plan" "plan" {
  name                = "${var.project_prefix}-asp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Windows"
  sku_name            = "F1" # Free tier to comply with policy
}

# Create the Windows Function App
resource "azurerm_windows_function_app" "func" {
  name                = var.function_app_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  service_plan_id            = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      dotnet_version = "6"
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"       = "dotnet",
    "AzureWebJobsStorage"            = azurerm_storage_account.storage.primary_connection_string,
    "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING" = azurerm_storage_account.storage.primary_connection_string,
    "WEBSITE_CONTENTSHARE"           = lower(var.function_app_name)
  }
}
