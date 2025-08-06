output "resource_group_name" {
  description = "The name of the created resource group."
  value       = azurerm_resource_group.rg.name
}

output "function_app_name" {
  description = "The name of the created Function App."
  value       = azurerm_windows_function_app.func.name
}

output "function_app_default_hostname" {
  description = "The default hostname of the Function App."
  value       = azurerm_windows_function_app.func.default_hostname
}
