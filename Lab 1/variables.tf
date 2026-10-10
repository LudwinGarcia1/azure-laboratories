variable "location" {
  description = "Región de Azure para el despliegue de recursos"
  type        = string
  default     = "mexicocentral"
}

variable "environment" {
  description = "Entorno de ciclo de vida (dev, qa, prod)"
  type        = string
  default     = "dev"
}

variable "resource_group_name" {
  description = "Nombre del Grupo de Recursos"
  type        = string
  default     = "rg-utvt-integradora-dev-mxc-001"
}

variable "workspace_name" {
  description = "Nombre del Log Analytics Workspace"
  type        = string
  default     = "log-utvt-integradora-dev-mxc-001"
}

variable "application_insights_name" {
  description = "Nombre de la instancia de Application Insights"
  type        = string
  default     = "appi-utvt-integradora-dev-mxc-001"
}

variable "app_service_plan_name" {
  description = "Nombre del App Service Plan"
  type        = string
  default     = "asp-utvt-integradora-dev-mxc-001"
}

variable "web_app_name" {
  description = "Nombre de la Web App en Azure"
  type        = string
  default     = "app-utvt-integradora-web-dev-mxc-001"
}

variable "os_type" {
  description = "Sistema operativo del plan de App Service"
  type        = string
  default     = "Windows"
}

variable "sku_name" {
  description = "Nivel de precios / SKU del App Service Plan"
  type        = string
  default     = "F1"
}
