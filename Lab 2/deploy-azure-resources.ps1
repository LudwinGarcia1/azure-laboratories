<#
.SYNOPSIS
    Script automatizado en PowerShell para el aprovisionamiento de la arquitectura
    del Proyecto Integrador (Laboratorio 2) en Microsoft Azure for Students.
.DESCRIPTION
    Aprovisiona:
    1. Grupo de Recursos (rg-utvt-integradora-dev-mxc-001)
    2. Red Virtual (10.0.0.0/16) y sus 5 subredes segmentadas
    3. Máquina Virtual Linux Ubuntu (Standard_B2ats_v2)
    4. Servidor de PostgreSQL Flexible Server con Private Endpoint y DNS Privado
    5. Creación de la base de datos 'integradora'
    6. Azure Storage Account con Private Endpoint y DNS Privado
    7. App Service Plan Linux y Web App con integración a VNet (VNet Integration)
.AUTHOR
    Ludwin García Gaytán (Matrícula: 222310777)
    Universidad Tecnológica del Valle de Toluca (UTVT)
#>

[CmdletBinding()]
param (
    [string]$ResourceGroupName = "rg-utvt-integradora-dev-mxc-001",
    [string]$Location          = "mexicocentral",
    [string]$VNetName          = "vnet-utvt-integradora-dev-mxc-001",
    [string]$VmName            = "vm-utvt-integradora-dev-mxc-001",
    [string]$PostgresServer    = "psql-utvt-integradora-dev-mxc-001",
    [string]$StorageAccount    = "stutvtintdevmxc001",
    [string]$AppServicePlan    = "asp-utvt-integradora-dev-mxc-001",
    [string]$WebAppName        = "app-utvt-integradora-web-dev-mxc-001",
    [string]$AdminUser         = "azureuser",
    [string]$AdminPassword     = "Utvt2026@PasswordSeguro!"
)

$ErrorActionPreference = "Stop"

Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host " INICIANDO DESPLIEGUE ARQUITECTURA PROYECTO INTEGRADOR (LAB 2)" -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan

# 1. Grupo de Recursos
Write-Host "[1/7] Verificando / Creando Grupo de Recursos '$ResourceGroupName'..." -ForegroundColor Yellow
az group create --name $ResourceGroupName --location $Location `
  --tags Environment="dev" Project="RestoHub" Materia="Arquitectura del Proyecto Integrador" `
         Institucion="UTVT" Alumno="Ludwin Garcia Gaytan" Matricula="222310777" | Out-Null

# 2. VNet y Subredes
Write-Host "[2/7] Creando Red Virtual '$VNetName' (10.0.0.0/16)..." -ForegroundColor Yellow
az network vnet create --resource-group $ResourceGroupName --name $VNetName `
  --address-prefixes 10.0.0.0/16 --location $Location | Out-Null

Write-Host "  -> Creando subred App Service (10.0.1.0/24)..." -ForegroundColor Gray
az network vnet subnet create --resource-group $ResourceGroupName --vnet-name $VNetName `
  --name "snet-utvt-integradora-app-dev-mxc-001" --address-prefixes 10.0.1.0/24 `
  --delegations "Microsoft.Web/serverFarms" | Out-Null

Write-Host "  -> Creando subred Base de Datos (10.0.2.0/24)..." -ForegroundColor Gray
az network vnet subnet create --resource-group $ResourceGroupName --vnet-name $VNetName `
  --name "snet-utvt-integradora-db-dev-mxc-001" --address-prefixes 10.0.2.0/24 | Out-Null

Write-Host "  -> Creando subred Máquina Virtual (10.0.3.0/24)..." -ForegroundColor Gray
az network vnet subnet create --resource-group $ResourceGroupName --vnet-name $VNetName `
  --name "snet-utvt-integradora-vm-dev-mxc-001" --address-prefixes 10.0.3.0/24 | Out-Null

Write-Host "  -> Creando subred Private Endpoints (10.0.4.0/24)..." -ForegroundColor Gray
az network vnet subnet create --resource-group $ResourceGroupName --vnet-name $VNetName `
  --name "snet-utvt-integradora-pe-dev-mxc-001" --address-prefixes 10.0.4.0/24 `
  --disable-private-endpoint-network-policies true | Out-Null

Write-Host "  -> Creando subred Azure Bastion (10.0.5.0/24)..." -ForegroundColor Gray
az network vnet subnet create --resource-group $ResourceGroupName --vnet-name $VNetName `
  --name "AzureBastionSubnet" --address-prefixes 10.0.5.0/24 | Out-Null

# 3. Máquina Virtual Linux
Write-Host "[3/7] Creando Máquina Virtual '$VmName'..." -ForegroundColor Yellow
az vm create --resource-group $ResourceGroupName --name $VmName `
  --image "Ubuntu2204" --size "Standard_B2ats_v2" `
  --vnet-name $VNetName --subnet "snet-utvt-integradora-vm-dev-mxc-001" `
  --admin-username $AdminUser --admin-password $AdminPassword --public-ip-address "" | Out-Null

# 4. PostgreSQL Flexible Server y Base de Datos
Write-Host "[4/7] Creando Azure Database for PostgreSQL Flexible Server '$PostgresServer'..." -ForegroundColor Yellow
az postgres flexible-server create --resource-group $ResourceGroupName --name $PostgresServer `
  --location $Location --admin-user $AdminUser --admin-password $AdminPassword `
  --sku-name "Standard_B1ms" --tier "Burstable" --storage-size 32 `
  --version 16 --public-access "Disabled" --yes | Out-Null

Write-Host "  -> Creando base de datos 'integradora' en el servidor..." -ForegroundColor Gray
az postgres flexible-server db create --resource-group $ResourceGroupName `
  --server-name $PostgresServer --database-name "integradora" | Out-Null

# 5. Storage Account
Write-Host "[5/7] Creando Azure Storage Account '$StorageAccount'..." -ForegroundColor Yellow
az storage account create --resource-group $ResourceGroupName --name $StorageAccount `
  --location $Location --sku "Standard_LRS" --encryption-services blob `
  --public-network-access "Disabled" --min-tls-version "TLS1_2" | Out-Null

# 6. App Service Plan y Web App
Write-Host "[6/7] Creando App Service Plan y Web App con integración a VNet..." -ForegroundColor Yellow
az appservice plan create --name $AppServicePlan --resource-group $ResourceGroupName `
  --location $Location --is-linux --sku "B1" | Out-Null

az webapp create --name $WebAppName --resource-group $ResourceGroupName `
  --plan $AppServicePlan --runtime "NODE:20-lts" | Out-Null

Write-Host "  -> Vinculando Web App a la subred 'snet-utvt-integradora-app-dev-mxc-001'..." -ForegroundColor Gray
az webapp vnet-integration add --resource-group $ResourceGroupName --name $WebAppName `
  --vnet $VNetName --subnet "snet-utvt-integradora-app-dev-mxc-001" | Out-Null

Write-Host "==============================================================" -ForegroundColor Green
Write-Host " DESPLIEGUE COMPLETADO EXITOSAMENTE" -ForegroundColor Green
Write-Host "==============================================================" -ForegroundColor Green
