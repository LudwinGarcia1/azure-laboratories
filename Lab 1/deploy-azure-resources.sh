#!/usr/bin/env bash
# ==========================================================
# UNIVERSIDAD TECNOLOGICA DEL VALLE DE TOLUCA
# Practica 12: Azure Portal - App Service (Laboratorio 1)
# Alumno: Ludwin Garcia Gaytan | Matricula: 222310777 (IDGS-81)
# ==========================================================
set -e

LOCATION="${1:-mexicocentral}"
RG_NAME="${2:-rg-utvt-integradora-dev-mxc-001}"
WS_NAME="${3:-log-utvt-integradora-dev-mxc-001}"
APPI_NAME="${4:-appi-utvt-integradora-dev-mxc-001}"
ASP_NAME="${5:-asp-utvt-integradora-dev-mxc-001}"
APP_NAME="${6:-app-utvt-integradora-web-dev-mxc-001}"

echo "=========================================================="
echo "  Despliegue de Recursos Azure en: $LOCATION"
echo "  Grupo de Recursos: $RG_NAME"
echo "=========================================================="

# 1. Resource Group
echo "[1/6] Creando Grupo de Recursos..."
az group create --name "$RG_NAME" --location "$LOCATION" --tags Environment=dev Project=integradora

# 2. Log Analytics
echo "[2/6] Creando Log Analytics Workspace..."
az monitor log-analytics workspace create \
    --resource-group "$RG_NAME" \
    --workspace-name "$WS_NAME" \
    --location "$LOCATION" \
    --sku PerGB2018 \
    --retention-time 30

# 3. Application Insights
echo "[3/6] Creando Application Insights..."
CONN_STRING=$(az monitor app-insights component create \
    --app "$APPI_NAME" \
    --location "$LOCATION" \
    --resource-group "$RG_NAME" \
    --workspace "$WS_NAME" \
    --application-type web \
    --query "connectionString" -o tsv)

# 4. App Service Plan
echo "[4/6] Creando App Service Plan..."
az appservice plan create \
    --name "$ASP_NAME" \
    --resource-group "$RG_NAME" \
    --sku F1 \
    --is-linux false \
    --location "$LOCATION"

# 5. Web App
echo "[5/6] Creando Web App..."
az webapp create \
    --name "$APP_NAME" \
    --resource-group "$RG_NAME" \
    --plan "$ASP_NAME" \
    --runtime "NODE:20LTS"

# 6. Integrar App Insights
echo "[6/6] Vinculando Application Insights con Web App..."
az webapp config appsettings set \
    --name "$APP_NAME" \
    --resource-group "$RG_NAME" \
    --settings \
        APPLICATIONINSIGHTS_CONNECTION_STRING="$CONN_STRING" \
        ApplicationInsightsAgent_EXTENSION_VERSION="~2"

echo "Despliegue finalizado con exito: https://$APP_NAME.azurewebsites.net"
