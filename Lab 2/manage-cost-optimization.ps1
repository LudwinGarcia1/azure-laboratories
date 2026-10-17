<#
.SYNOPSIS
    Script de optimización de costos para entornos Azure for Students.
.DESCRIPTION
    Detiene o inicia los recursos de cómputo que generan consumo por hora (VM y PostgreSQL Flexible Server).
.EXAMPLE
    .\manage-cost-optimization.ps1 -Action Stop
    .\manage-cost-optimization.ps1 -Action Start
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("Stop", "Start", "Status")]
    [string]$Action,

    [string]$ResourceGroupName = "rg-utvt-integradora-dev-mxc-001",
    [string]$VmName            = "vm-utvt-integradora-dev-mxc-001",
    [string]$PostgresServer    = "psql-utvt-integradora-dev-mxc-001"
)

Write-Host ">>> Ejecutando acción '$Action' para optimización de costos..." -ForegroundColor Cyan

if ($Action -eq "Stop") {
    Write-Host "-> Desasignando Máquina Virtual '$VmName'..." -ForegroundColor Yellow
    az vm deallocate --resource-group $ResourceGroupName --name $VmName --no-wait
    Write-Host "   VM marcada para desasignación (cómputo pausado)." -ForegroundColor Green

    Write-Host "-> Deteniendo Azure Database for PostgreSQL '$PostgresServer'..." -ForegroundColor Yellow
    az postgres flexible-server stop --resource-group $ResourceGroupName --name $PostgresServer
    Write-Host "   PostgreSQL Flexible Server detenido exitosamente." -ForegroundColor Green
}
elseif ($Action -eq "Start") {
    Write-Host "-> Iniciando Azure Database for PostgreSQL '$PostgresServer'..." -ForegroundColor Yellow
    az postgres flexible-server start --resource-group $ResourceGroupName --name $PostgresServer
    Write-Host "   PostgreSQL Flexible Server iniciado." -ForegroundColor Green

    Write-Host "-> Iniciando Máquina Virtual '$VmName'..." -ForegroundColor Yellow
    az vm start --resource-group $ResourceGroupName --name $VmName --no-wait
    Write-Host "   VM iniciada exitosamente." -ForegroundColor Green
}
elseif ($Action -eq "Status") {
    Write-Host "=== ESTADO DE LA MÁQUINA VIRTUAL ===" -ForegroundColor Magenta
    az vm get-instance-view --resource-group $ResourceGroupName --name $VmName `
      --query "instanceView.statuses[?starts_with(code, 'PowerState/')].displayStatus" -o tsv

    Write-Host "=== ESTADO DE POSTGRESQL ===" -ForegroundColor Magenta
    az postgres flexible-server show --resource-group $ResourceGroupName --name $PostgresServer `
      --query "state" -o tsv
}
