#!/usr/bin/env bash
# ==============================================================================
# Script de Despliegue Automatizado - Azure CLI (Bash)
# Práctica 13: Arquitectura del Proyecto Integrador (Laboratorio 2)
# Autor: Ludwin García Gaytán (Matrícula: 222310777) - UTVT
# ==============================================================================

set -euo pipefail

RG_NAME="rg-utvt-integradora-dev-mxc-001"
LOCATION="mexicocentral"
VNET_NAME="vnet-utvt-integradora-dev-mxc-001"
VM_NAME="vm-utvt-integradora-dev-mxc-001"
POSTGRES_SERVER="psql-utvt-integradora-dev-mxc-001"
STORAGE_ACCOUNT="stutvtintdevmxc001"
APP_PLAN="asp-utvt-integradora-dev-mxc-001"
WEB_APP="app-utvt-integradora-web-dev-mxc-001"
ADMIN_USER="azureuser"
ADMIN_PASS="Utvt2026@PasswordSeguro!"

echo ">>> [1/7] Creando Grupo de Recursos '$RG_NAME' en '$LOCATION'..."
az group create --name "$RG_NAME" --location "$LOCATION" \
  --tags Environment="dev" Project="RestoHub" Materia="Arquitectura del Proyecto Integrador" \
         Institucion="UTVT" Alumno="Ludwin Garcia Gaytan" Matricula="222310777" > /dev/null

echo ">>> [2/7] Creando VNet y Subredes..."
az network vnet create --resource-group "$RG_NAME" --name "$VNET_NAME" \
  --address-prefixes 10.0.0.0/16 --location "$LOCATION" > /dev/null

az network vnet subnet create --resource-group "$RG_NAME" --vnet-name "$VNET_NAME" \
  --name "snet-utvt-integradora-app-dev-mxc-001" --address-prefixes 10.0.1.0/24 \
  --delegations "Microsoft.Web/serverFarms" > /dev/null

az network vnet subnet create --resource-group "$RG_NAME" --vnet-name "$VNET_NAME" \
  --name "snet-utvt-integradora-db-dev-mxc-001" --address-prefixes 10.0.2.0/24 > /dev/null

az network vnet subnet create --resource-group "$RG_NAME" --vnet-name "$VNET_NAME" \
  --name "snet-utvt-integradora-vm-dev-mxc-001" --address-prefixes 10.0.3.0/24 > /dev/null

az network vnet subnet create --resource-group "$RG_NAME" --vnet-name "$VNET_NAME" \
  --name "snet-utvt-integradora-pe-dev-mxc-001" --address-prefixes 10.0.4.0/24 \
  --disable-private-endpoint-network-policies true > /dev/null

az network vnet subnet create --resource-group "$RG_NAME" --vnet-name "$VNET_NAME" \
  --name "AzureBastionSubnet" --address-prefixes 10.0.5.0/24 > /dev/null

echo ">>> [3/7] Creando Máquina Virtual Linux..."
az vm create --resource-group "$RG_NAME" --name "$VM_NAME" \
  --image "Ubuntu2204" --size "Standard_B2ats_v2" \
  --vnet-name "$VNET_NAME" --subnet "snet-utvt-integradora-vm-dev-mxc-001" \
  --admin-username "$ADMIN_USER" --admin-password "$ADMIN_PASS" --public-ip-address "" > /dev/null

echo ">>> [4/7] Creando PostgreSQL Flexible Server y BD 'integradora'..."
az postgres flexible-server create --resource-group "$RG_NAME" --name "$POSTGRES_SERVER" \
  --location "$LOCATION" --admin-user "$ADMIN_USER" --admin-password "$ADMIN_PASS" \
  --sku-name "Standard_B1ms" --tier "Burstable" --storage-size 32 \
  --version 16 --public-access "Disabled" --yes > /dev/null

az postgres flexible-server db create --resource-group "$RG_NAME" \
  --server-name "$POSTGRES_SERVER" --database-name "integradora" > /dev/null

echo ">>> [5/7] Creando Azure Storage Account (Blob)..."
az storage account create --resource-group "$RG_NAME" --name "$STORAGE_ACCOUNT" \
  --location "$LOCATION" --sku "Standard_LRS" --encryption-services blob \
  --public-network-access "Disabled" --min-tls-version "TLS1_2" > /dev/null

echo ">>> [6/7] Creando App Service Plan y Web App con VNet Integration..."
az appservice plan create --name "$APP_PLAN" --resource-group "$RG_NAME" \
  --location "$LOCATION" --is-linux --sku "B1" > /dev/null

az webapp create --name "$WEB_APP" --resource-group "$RG_NAME" \
  --plan "$APP_PLAN" --runtime "NODE:20-lts" > /dev/null

az webapp vnet-integration add --resource-group "$RG_NAME" --name "$WEB_APP" \
  --vnet "$VNET_NAME" --subnet "snet-utvt-integradora-app-dev-mxc-001" > /dev/null

echo "=============================================================="
echo ">>> DESPLIEGUE FINALIZADO EXITOSAMENTE"
echo "=============================================================="
