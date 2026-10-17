variable "resource_group_name" {
  description = "Nombre oficial del Grupo de Recursos bajo convención CAF"
  type        = string
  default     = "rg-utvt-integradora-dev-mxc-001"
}

variable "location" {
  description = "Región de Azure para el despliegue de infraestructura"
  type        = string
  default     = "mexicocentral"
}

variable "environment" {
  description = "Identificador del entorno de ciclo de vida (dev, qa, prod)"
  type        = string
  default     = "dev"
}

variable "vnet_name" {
  description = "Nombre de la Red Virtual principal"
  type        = string
  default     = "vnet-utvt-integradora-dev-mxc-001"
}

variable "vnet_address_space" {
  description = "Espacio de direccionamiento CIDR de la Red Virtual"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "snet_app_prefix" {
  description = "Prefijo CIDR de la subred para integración de App Service"
  type        = string
  default     = "10.0.1.0/24"
}

variable "snet_db_prefix" {
  description = "Prefijo CIDR de la subred reservada para bases de datos"
  type        = string
  default     = "10.0.2.0/24"
}

variable "snet_vm_prefix" {
  description = "Prefijo CIDR de la subred para máquinas virtuales (Workers)"
  type        = string
  default     = "10.0.3.0/24"
}

variable "snet_pe_prefix" {
  description = "Prefijo CIDR de la subred para Private Endpoints"
  type        = string
  default     = "10.0.4.0/24"
}

variable "snet_bastion_prefix" {
  description = "Prefijo CIDR de la subred dedicada para Azure Bastion Host"
  type        = string
  default     = "10.0.5.0/24"
}

variable "vm_name" {
  description = "Nombre de la máquina virtual Linux de desarrollo / worker"
  type        = string
  default     = "vm-utvt-integradora-dev-mxc-001"
}

variable "vm_size" {
  description = "Tamaño de SKU para la máquina virtual Linux"
  type        = string
  default     = "Standard_B2ats_v2"
}

variable "admin_username" {
  description = "Nombre del usuario administrador de la máquina virtual y PostgreSQL"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Contraseña segura del administrador (cumple con complejidad Azure)"
  type        = string
  default     = "Utvt2026@PasswordSeguro!"
  sensitive   = true
}

variable "postgres_server_name" {
  description = "Nombre del servidor de Azure Database for PostgreSQL Flexible Server"
  type        = string
  default     = "psql-utvt-integradora-dev-mxc-001"
}

variable "storage_account_name" {
  description = "Nombre globalmente único para la cuenta de almacenamiento Blob Storage"
  type        = string
  default     = "stutvtintdevmxc001"
}

variable "app_service_plan_name" {
  description = "Nombre del App Service Plan en Linux"
  type        = string
  default     = "asp-utvt-integradora-dev-mxc-001"
}

variable "web_app_name" {
  description = "Nombre de la aplicación Web App en Linux"
  type        = string
  default     = "app-utvt-integradora-web-dev-mxc-001"
}
