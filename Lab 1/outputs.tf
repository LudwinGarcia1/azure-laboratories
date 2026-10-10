output "resource_group_name" {
  description = "Nombre del Resource Group creado"
  value       = azurerm_resource_group.rg.name
}

output "log_analytics_id" {
  description = "ID del Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.log.id
}

output "app_insights_connection_string" {
  description = "Cadena de conexión de Application Insights"
  value       = azurerm_application_insights.appi.connection_string
  sensitive   = true
}

output "app_service_plan_id" {
  description = "ID del App Service Plan"
  value       = azurerm_service_plan.asp.id
}

output "web_app_default_hostname" {
  description = "URL / FQDN por defecto de la Web App"
  value       = azurerm_windows_web_app.app.default_hostname
}
