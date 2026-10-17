output "resource_group_name" {
  description = "Nombre del Grupo de Recursos aprovisionado"
  value       = azurerm_resource_group.rg.name
}

output "vnet_id" {
  description = "ID de la Red Virtual principal"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_subnets" {
  description = "Lista de subredes creadas en la arquitectura"
  value = {
    app_subnet     = azurerm_subnet.snet_app.id
    db_subnet      = azurerm_subnet.snet_db.id
    vm_subnet      = azurerm_subnet.snet_vm.id
    pe_subnet      = azurerm_subnet.snet_pe.id
    bastion_subnet = azurerm_subnet.snet_bastion.id
  }
}

output "vm_private_ip" {
  description = "Dirección IP privada asignada a la máquina virtual"
  value       = azurerm_network_interface.nic_vm.private_ip_address
}

output "postgres_fqdn" {
  description = "Nombre de dominio totalmente calificado (FQDN) de PostgreSQL"
  value       = azurerm_postgresql_flexible_server.psql.fqdn
}

output "postgres_private_endpoint_ip" {
  description = "Dirección IP privada asignada al Private Endpoint de PostgreSQL"
  value       = azurerm_private_endpoint.pep_psql.private_service_connection[0].private_ip_address
}

output "storage_account_blob_endpoint" {
  description = "Endpoint del servicio Blob de la cuenta de almacenamiento"
  value       = azurerm_storage_account.st.primary_blob_endpoint
}

output "web_app_default_hostname" {
  description = "Hostname público predeterminado del App Service"
  value       = azurerm_linux_web_app.app.default_hostname
}
