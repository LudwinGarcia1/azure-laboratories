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

locals {
  common_tags = {
    Environment = var.environment
    Project     = "Restaurant Hub (RestoHub) / Callejón 9"
    Materia     = "Arquitectura del Proyecto Integrador"
    Institucion = "Universidad Tecnológica del Valle de Toluca (UTVT)"
    Carrera     = "Ingeniería en Desarrollo y Gestión de Software"
    Grupo       = "IDGS 101"
    Alumno      = "Ludwin García Gaytán"
    Matricula   = "222310777"
  }
}

# 1. Grupo de Recursos Principal
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# 2. Red Virtual (VNet)
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.vnet_address_space
  tags                = local.common_tags
}

# 3. Subredes Segmentadas
# 3.1 Subred para Integración de App Service (con Delegación)
resource "azurerm_subnet" "snet_app" {
  name                 = "snet-utvt-integradora-app-dev-mxc-001"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.snet_app_prefix]

  delegation {
    name = "delegation-appservice"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# 3.2 Subred Reservada para Base de Datos
resource "azurerm_subnet" "snet_db" {
  name                 = "snet-utvt-integradora-db-dev-mxc-001"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.snet_db_prefix]
}

# 3.3 Subred para Máquina Virtual (Workers / Procesamiento)
resource "azurerm_subnet" "snet_vm" {
  name                 = "snet-utvt-integradora-vm-dev-mxc-001"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.snet_vm_prefix]
}

# 3.4 Subred para Puntos de Conexión Privados (Private Endpoints)
resource "azurerm_subnet" "snet_pe" {
  name                                          = "snet-utvt-integradora-pe-dev-mxc-001"
  resource_group_name                           = azurerm_resource_group.rg.name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = [var.snet_pe_prefix]
  private_endpoint_network_policies_enabled     = false
}

# 3.5 Subred Dedicada para Azure Bastion
resource "azurerm_subnet" "snet_bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.snet_bastion_prefix]
}

# 4. Network Security Groups (NSGs)
resource "azurerm_network_security_group" "nsg_vm" {
  name                = "nsg-utvt-integradora-vm-dev-mxc-001"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags

  security_rule {
    name                       = "Allow-SSH-Internal"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc_vm" {
  subnet_id                 = azurerm_subnet.snet_vm.id
  network_security_group_id = azurerm_network_security_group.nsg_vm.id
}

# 5. Máquina Virtual Linux (Worker / Background Processing)
resource "azurerm_network_interface" "nic_vm" {
  name                = "nic-utvt-integradora-vm-dev-mxc-001"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "ipconfig-vm"
    subnet_id                     = azurerm_subnet.snet_vm.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.vm_name
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.nic_vm.id]
  tags                            = local.common_tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

# 6. Azure Database for PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "psql" {
  name                   = var.postgres_server_name
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "16"
  administrator_login    = var.admin_username
  administrator_password = var.admin_password
  sku_name               = "B_Standard_B1ms"
  storage_mb             = 32768
  zone                   = "1"
  tags                   = local.common_tags
}

# 6.1 Base de Datos de Aplicación en PostgreSQL
resource "azurerm_postgresql_flexible_server_database" "db_integradora" {
  name      = "integradora"
  server_id = azurerm_postgresql_flexible_server.psql.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# 6.2 Zona DNS Privada para PostgreSQL
resource "azurerm_private_dns_zone" "dns_psql" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_link_psql" {
  name                  = "vnetlink-psql-utvt"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_psql.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

# 6.3 Private Endpoint para PostgreSQL Flexible Server
resource "azurerm_private_endpoint" "pep_psql" {
  name                = "pep-utvt-integradora-db-dev-mxc-001"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.snet_pe.id
  tags                = local.common_tags

  custom_network_interface_name = "nic-utvt-integradora-pe-db-dev-mxc-001"

  private_service_connection {
    name                           = "psc-psql-utvt"
    private_connection_resource_id = azurerm_postgresql_flexible_server.psql.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_psql.id]
  }
}

# 7. Azure Storage Account (Blob Storage)
resource "azurerm_storage_account" "st" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  public_network_access_enabled = false
  tags                     = local.common_tags
}

# 7.1 Zona DNS Privada para Blob Storage
resource "azurerm_private_dns_zone" "dns_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_link_blob" {
  name                  = "vnetlink-blob-utvt"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_blob.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

# 7.2 Private Endpoint para Blob Storage
resource "azurerm_private_endpoint" "pep_blob" {
  name                = "pep-utvt-integradora-blob-dev-mxc-001"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.snet_pe.id
  tags                = local.common_tags

  custom_network_interface_name = "nic-utvt-integradora-pe-blob-dev-mxc-001"

  private_service_connection {
    name                           = "psc-blob-utvt"
    private_connection_resource_id = azurerm_storage_account.st.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_blob.id]
  }
}

# 8. Observabilidad (Log Analytics y Application Insights)
resource "azurerm_log_analytics_workspace" "log" {
  name                = "log-utvt-integradora-dev-mxc-001"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.common_tags
}

resource "azurerm_application_insights" "appi" {
  name                = "appi-utvt-integradora-dev-mxc-001"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.log.id
  application_type    = "web"
  tags                = local.common_tags
}

# 9. App Service Plan (Linux)
resource "azurerm_service_plan" "asp" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
  tags                = local.common_tags
}

# 10. Web App con Integración a VNet
resource "azurerm_linux_web_app" "app" {
  name                = var.web_app_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.asp.id
  tags                = local.common_tags

  site_config {
    always_on = true
    application_stack {
      node_version = "20-lts"
    }
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.appi.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.appi.connection_string
    "DATABASE_HOST"                         = "psql-utvt-integradora-dev-mxc-001.privatelink.postgres.database.azure.com"
    "DATABASE_NAME"                         = "integradora"
    "STORAGE_BLOB_ENDPOINT"                 = azurerm_storage_account.st.primary_blob_endpoint
  }
}

# 10.1 Integración de Red Virtual (VNet Integration)
resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  app_service_id = azurerm_linux_web_app.app.id
  subnet_id      = azurerm_subnet.snet_app.id
}
