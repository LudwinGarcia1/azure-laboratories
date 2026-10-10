terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

provider "azurerm" {
  features {}
}

# 1. Grupo de Recursos
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    Project     = "integradora"
    Materia     = "Evaluacion y Mejora para el Desarrollo de Software"
    Alumno      = "Ludwin Garcia Gaytan"
    Matricula   = "222310777"
    Grupo       = "IDGS-81"
  }
}

# 2. Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "log" {
  name                = var.workspace_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = azurerm_resource_group.rg.tags
}

# 3. Application Insights
resource "azurerm_application_insights" "appi" {
  name                = var.application_insights_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.log.id
  application_type    = "web"

  tags = azurerm_resource_group.rg.tags
}

# 4. App Service Plan
resource "azurerm_service_plan" "asp" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = var.os_type
  sku_name            = var.sku_name

  tags = azurerm_resource_group.rg.tags
}

# 5. Web App
resource "azurerm_windows_web_app" "app" {
  name                = var.web_app_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    always_on = false
    application_stack {
      node_version = "~20"
    }
  }

  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = azurerm_application_insights.appi.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~2"
    "XDT_MicrosoftApplicationInsights_Mode"      = "recommended"
    "WEBSITE_NODE_DEFAULT_VERSION"              = "~20"
    "ENVIRONMENT"                               = var.environment
  }

  tags = azurerm_resource_group.rg.tags
}
