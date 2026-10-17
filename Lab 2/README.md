# Laboratorio 2: Arquitectura del Proyecto Integrador en Microsoft Azure

> **Asignatura:** Arquitectura del Proyecto Integrador / Integradora  
> **Institución:** Universidad Tecnológica del Valle de Toluca (UTVT)  
> **Carrera:** Ingeniería en Desarrollo y Gestión de Software (IDGS 101 — 10mo Cuatrimestre)  
> **Docente:** Mtro. Jorge Almeida Montiel  
> **Equipo / Estudiantes:**  
> - **García Gaytán Ludwin** (Líder de Proyecto — Matrícula: 222310777)  
> - **Duarte Villavicencio Octavio** (Matrícula: 222310422)  
> - **Mercado Serrano Valeria** (Matrícula: 222310838)  
> - **Hernández Mejía Braulio** (Matrícula: 222310435)  
> **Proyecto Integrador:** Restaurant Hub (RestoHub) / Callejón 9  

---

## 1. Descripción General del Laboratorio

El objetivo de esta práctica es diseñar, estructurar y aprovisionar la arquitectura en la nube de nivel empresarial para el proyecto integrador **RestoHub (Restaurante Callejón 9)** sobre **Microsoft Azure for Students**, implementando los pilares de seguridad, aislamiento de red y eficiencia de costos del **Azure Well-Architected Framework** y la convención de gobernanza del **Cloud Adoption Framework (CAF)**.

A diferencia de despliegues tradicionales expuestos a Internet, esta arquitectura implementa un **enfoque Zero-Trust** donde los servicios PaaS críticos (Base de datos relacional y Almacenamiento de blobs) tienen el acceso público completamente deshabilitado y se comunican con los componentes de cómputo (Web App y VM de backend) de manera privada y encriptada mediante **Private Endpoints (Azure Private Link)** y **Zonas DNS Privadas**.

---

## 2. Diagrama de Arquitectura de Referencia

La arquitectura implementa una topología de red Landing Zone adaptada a los créditos de Azure for Students:

![Arquitectura Azure Students Integradora](arquitectura-azure-students%20integradora.png)

### Comparativa Multicloud (AWS vs. Azure)
Para fines de portabilidad y análisis de costos, se diseñó también el mapeo de componentes hacia Amazon Web Services (AWS):

![Arquitectura AWS Integradora](arquitectura-aws%20integradora.png)

---

## 3. Matriz de Direccionamiento IP y Segmentación de Red

La red virtual principal **`vnet-utvt-integradora-dev-mxc-001`** opera bajo el bloque **`10.0.0.0/16`** en la región **Mexico Central (mxc)**, segmentada en 5 subredes dedicadas:

| Recurso / Propósito | Nombre Oficial (CAF) | Prefijo CIDR | Directiva / Delegación |
| :--- | :--- | :--- | :--- |
| **Red Virtual Principal** | `vnet-utvt-integradora-dev-mxc-001` | `10.0.0.0/16` | Espacio global de red |
| **Integración de App Service** | `snet-utvt-integradora-app-dev-mxc-001` | `10.0.1.0/24` | Delegada a `Microsoft.Web/serverFarms` |
| **Base de Datos (Reservada)** | `snet-utvt-integradora-db-dev-mxc-001` | `10.0.2.0/24` | Tráfico aislado de persistencia |
| **Máquina Virtual (Worker)** | `snet-utvt-integradora-vm-dev-mxc-001` | `10.0.3.0/24` | Procesamiento asíncrono y tareas batch |
| **Puntos de Conexión Privados** | `snet-utvt-integradora-pe-dev-mxc-001` | `10.0.4.0/24` | `PrivateEndpointNetworkPolicies = Disabled` |
| **Azure Bastion Dedicado** | `AzureBastionSubnet` | `10.0.5.0/24` | Administración segura sin IPs públicas |

---

## 4. Componentes y Servicios Aprovisionados

### 4.1 Cómputo e Interfaz de Usuario
- **App Service Plan:** `asp-utvt-integradora-dev-mxc-001` (Linux, SKU B1 Basic).
- **Web App:** `app-utvt-integradora-web-dev-mxc-001` (Node.js 20 LTS).
  - Configurado con **VNet Integration (Integración de red virtual Swift)** hacia la subred `snet-utvt-integradora-app-dev-mxc-001`. Permite resolver y enviar paquetes TCP privados hacia los Private Endpoints de PostgreSQL y Blob Storage.
- **Máquina Virtual (Worker):** `vm-utvt-integradora-dev-mxc-001` (Ubuntu Linux 22.04 LTS, SKU `Standard_B2ats_v2` / `B1s`). Ejecuta procesos de analítica en segundo plano, workers de WebSockets y sincronización de inventarios.

### 4.2 Persistencia de Datos y Puntos de Conexión Privados
- **Azure Database for PostgreSQL Flexible Server:**
  - Instancia: `psql-utvt-integradora-dev-mxc-001` (Burstable B1ms, PostgreSQL 16, 32 GB Storage).
  - Base de Datos de Producción/Dev: `integradora` (UTF-8, en_US.utf8).
  - Private Endpoint: `pep-utvt-integradora-db-dev-mxc-001` vinculado a `snet-utvt-integradora-pe-dev-mxc-001`.
  - Zona DNS Privada: `privatelink.postgres.database.azure.com`.
  - Acceso Público: **Deshabilitado**.
- **Azure Storage Account (Blob Storage):**
  - Cuenta: `stutvtintdevmxc001` (Standard LRS, TLS 1.2).
  - Contenedor para archivos multimedia, códigos QR de mesas y comandas PDF.
  - Private Endpoint: `pep-utvt-integradora-blob-dev-mxc-001`.
  - Zona DNS Privada: `privatelink.blob.core.windows.net`.
  - Acceso Público: **Deshabilitado**.

### 4.3 Monitoreo y Observabilidad
- **Log Analytics Workspace:** `log-utvt-integradora-dev-mxc-001` (Retención de 30 días).
- **Application Insights:** `appi-utvt-integradora-dev-mxc-001` (APM vinculado nativamente al workspace).

---

## 5. Mapeo de Pasos Prácticos (Videos del Laboratorio)

| Video | Tema | Descripción Técnica Implementada |
| :---: | :--- | :--- |
| **1** | Diagrama de infraestructura | Análisis de la arquitectura Landing Zone Well-Architected para Azure for Students. |
| **2** | Creación de VNet y Subnets | Creación de la red virtual `10.0.0.0/16` y particionamiento en las 5 subredes `/24`. |
| **3** | Máquina Virtual - Parte 1 | Configuración inicial de VM Linux Ubuntu (B2ats_v2), credenciales de administrador y discos. |
| **4** | Máquina Virtual - Parte 2 | Asignación a `snet-utvt-integradora-vm-dev-mxc-001`, NSG interno y deshabilitación de IP pública directa. |
| **5** | Máquina Virtual - Parte 3 | Validación final del despliegue de cómputo en el grupo de recursos. |
| **6** | PostgreSQL Flexible Server | Aprovisionamiento de `psql-utvt-integradora-dev-mxc-001` en SKU B1ms con PostgreSQL 16. |
| **7** | Private Endpoint PostgreSQL | Conexión privada en `snet-utvt-integradora-pe-dev-mxc-001` y zona DNS privada para postgres. |
| **8** | Creación de una nueva BD | Ejecución del comando CLI `az postgres flexible-server db create -n integradora`. |
| **9** | Detener VM y Servidor BD | Estrategia de optimización de crédito (Stop/Deallocate) para pausar cobros por hora. |
| **10** | Componentes creados | Auditoría global y verificación de estado en el portal de Azure. |
| **11** | Blob Storage | Despliegue de la cuenta de almacenamiento de objetos `stutvtintdevmxc001` con TLS 1.2. |
| **12** | Private Endpoint - Blob | Aislamiento de Blob Storage mediante `pep-utvt-integradora-blob-dev-mxc-001` y DNS privado. |
| **13** | Nuevo App Service con VNet | Despliegue del Web App Linux con VNet Integration hacia `snet-utvt-integradora-app-dev-mxc-001`. |

---

## 6. Estrategia de Optimización de Costos en Azure for Students

En suscripciones académicas (`Azure for Students`), los créditos disponibles deben protegerse contra consumo ocioso. Para ello se incluye el script de gestión:

```powershell
# Detener y desasignar VM y PostgreSQL al finalizar la sesión de laboratorio:
.\manage-cost-optimization.ps1 -Action Stop

# Reanudar servicios para pruebas o demostración:
.\manage-cost-optimization.ps1 -Action Start

# Consultar estado actual:
.\manage-cost-optimization.ps1 -Action Status
```

---

## 7. Despliegue con Infraestructura como Código (IaC)

### Despliegue con Terraform
```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### Despliegue con Azure Bicep
```bash
az deployment group create \
  --resource-group rg-utvt-integradora-dev-mxc-001 \
  --template-file bicep/main.bicep
```

### Despliegue con Script PowerShell
```powershell
.\deploy-azure-resources.ps1
```
