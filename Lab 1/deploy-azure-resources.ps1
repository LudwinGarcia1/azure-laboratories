<#
.SYNOPSIS
    Script de despliegue automatizado en Azure CLI para la Práctica 12 (Azure App Service - Lab 1).
.DESCRIPTION
    Aprovisiona los componentes de la matriz de arquitectura del laboratorio:
    - Grupo de Recursos: rg-utvt-integradora-dev-mxc-001
    - Log Analytics Workspace: log-utvt-integradora-dev-mxc-001
    - Application Insights: appi-utvt-integradora-dev-mxc-001
    - App Service Plan: asp-utvt-integradora-dev-mxc-001 (F1 Free)
    - Web App: app-utvt-integradora-web-dev-mxc-001 (Node 20 LTS)
    - Vinculación de Application Insights con App Service
.AUTHOR
    Ludwin García Gaytán (Matrícula: 222310777 - IDGS-81)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Location = "mexicocentral",

    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "rg-utvt-integradora-dev-mxc-001",

    [Parameter(Mandatory=$false)]
    [string]$WorkspaceName = "log-utvt-integradora-dev-mxc-001",

    [Parameter(Mandatory=$false)]
    [string]$AppInsightsName = "appi-utvt-integradora-dev-mxc-001",

    [Parameter(Mandatory=$false)]
    [string]$AppServicePlanName = "asp-utvt-integradora-dev-mxc-001",

    [Parameter(Mandatory=$false)]
    [string]$WebAppName = "app-utvt-integradora-web-dev-mxc-001"
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  UNIVERSIDAD TECNOLOGICA DEL VALLE DE TOLUCA" -ForegroundColor Cyan
Write-Host "  Practica 12: Azure Portal - App Service (Laboratorio 1)" -ForegroundColor Cyan
Write-Host "  Alumno: Ludwin Garcia Gaytan | Matricula: 222310777" -ForegroundColor Cyan
Write-Host "  Entorno: Desarrollo (dev) | Region: $Location" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Grupo de Recursos
Write-Host "`n[1/6] Creando Grupo de Recursos '$ResourceGroupName'..." -ForegroundColor Yellow
az group create --name $ResourceGroupName --location $Location --tags Environment=dev Project=integradora Student="Ludwin Garcia"

# 2. Log Analytics Workspace
Write-Host "`n[2/6] Creando Log Analytics Workspace '$WorkspaceName'..." -ForegroundColor Yellow
az monitor log-analytics workspace create `
    --resource-group $ResourceGroupName `
    --workspace-name $WorkspaceName `
    --location $Location `
    --sku PerGB2018 `
    --retention-time 30

# 3. Application Insights
Write-Host "`n[3/6] Creando Application Insights '$AppInsightsName'..." -ForegroundColor Yellow
$appInsights = az monitor app-insights component create `
    --app $AppInsightsName `
    --location $Location `
    --resource-group $ResourceGroupName `
    --workspace $WorkspaceName `
    --application-type web | ConvertFrom-Json

$connString = $appInsights.connectionString
Write-Host "Application Insights Connection String: $connString" -ForegroundColor Green

# 4. App Service Plan
Write-Host "`n[4/6] Creando App Service Plan '$AppServicePlanName'..." -ForegroundColor Yellow
az appservice plan create `
    --name $AppServicePlanName `
    --resource-group $ResourceGroupName `
    --sku F1 `
    --is-linux $false `
    --location $Location

# 5. Web App
Write-Host "`n[5/6] Creando Web App '$WebAppName'..." -ForegroundColor Yellow
az webapp create `
    --name $WebAppName `
    --resource-group $ResourceGroupName `
    --plan $AppServicePlanName `
    --runtime "NODE:20LTS"

# 6. Vincular Application Insights con Web App
Write-Host "`n[6/6] Vinculando Application Insights a Web App..." -ForegroundColor Yellow
az webapp config appsettings set `
    --name $WebAppName `
    --resource-group $ResourceGroupName `
    --settings `
        APPLICATIONINSIGHTS_CONNECTION_STRING="$connString" `
        ApplicationInsightsAgent_EXTENSION_VERSION="~2" `
        XDT_MicrosoftApplicationInsights_Mode="recommended"

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "  DESPLIEGUE FINALIZADO EXITOSAMENTE" -ForegroundColor Green
Write-Host "  Web App URL: https://$WebAppName.azurewebsites.net" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
