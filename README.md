# Laboratorios de Infraestructura en la Nube — Microsoft Azure

[![Azure](https://img.shields.io/badge/Microsoft_Azure-Landing_Zone-0078D4?logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/)
[![Node.js](https://img.shields.io/badge/Runtime-Node.js_20_LTS-339933?logo=nodedotjs&logoColor=white)](https://nodejs.org/)
[![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL_16-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Terraform](https://img.shields.io/badge/IaC-Terraform_1.16-844FBA?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![UTVT](https://img.shields.io/badge/Institución-UTVT-green)](https://utvt.edomex.gob.mx/)
[![Author](https://img.shields.io/badge/Autor-Ludwin%20García%20Gaytán-5C4EE5)](https://github.com/LudwinGarcia1)

Repositorio oficial de prácticas y proyectos de **Computación en la Nube, Plataforma como Servicio (PaaS) e Infraestructura Segura (IaaS / Landing Zone)** en **Microsoft Azure for Students**, correspondiente a las asignaturas del área de software en la **Universidad Tecnológica del Valle de Toluca (UTVT)**.

---

## 📌 Datos Institucionales y del Proyecto Integrador

* **Institución:** Universidad Tecnológica del Valle de Toluca (UTVT)
* **Dirección:** Dirección de Carrera de Tecnologías de la Información y Comunicación
* **Carrera:** Ingeniería en Desarrollo y Gestión de Software (IDGS)
* **Grupo y Cuatrimestre:** IDGS 101 — 10mo Cuatrimestre
* **Docente Titular:** Mtro. Jorge Almeida Montiel
* **Proyecto Integrador:** Restaurant Hub (RestoHub) / Callejón 9
* **Equipo de Trabajo:**
  * **García Gaytán Ludwin** (Líder de Proyecto — Matrícula: `222310777`)
  * **Duarte Villavicencio Octavio** (Matrícula: `222310422`)
  * **Mercado Serrano Valeria** (Matrícula: `222310838`)
  * **Hernández Mejía Braulio** (Matrícula: `222310435`)

---

## 📚 Laboratorios Disponibles

### 🔹 [Laboratorio 1: Azure App Service, Log Analytics y Application Insights](Lab%201) (Asignación 12)
* Aprovisionamiento del grupo de recursos `rg-utvt-integradora-dev-mxc-001`.
* Monitoreo y telemetría APM con Log Analytics Workspace y Application Insights (Workspace-based).
* App Service Plan y Web App con runtime Node.js 20 LTS.
* Entregable: [`docs/Reporte_Practica12_Azure_App_Service.docx`](docs/Reporte_Practica12_Azure_App_Service.docx).

### 🔹 [Laboratorio 2: Arquitectura del Proyecto Integrador (Landing Zone & Private Endpoints)](Lab%202) (Asignación 13)
* Diseño de Landing Zone alineada al Azure Well-Architected Framework en Azure for Students.
* Segmentación de red virtual (`vnet-utvt-integradora-dev-mxc-001` - `10.0.0.0/16`) en 5 subredes `/24`.
* Cómputo Linux (`vm-utvt-integradora-dev-mxc-001` - Ubuntu Server 22.04 LTS en B2ats_v2 / B1s).
* Azure Database for PostgreSQL Flexible Server (`psql-utvt-integradora-dev-mxc-001`) con base de datos `integradora`.
* Azure Storage Account (`stutvtintdevmxc001`) para Blob Storage.
* Seguridad Zero-Trust con Private Endpoints y Zonas DNS Privadas para PostgreSQL y Blob Storage (acceso público deshabilitado).
* Integración de Red Virtual (VNet Integration) en Azure App Service.
* Estrategia FinOps de parada y desasignación (Stop / Deallocate) para conservación de créditos de estudiantes.
* Entregable: [`docs/Reporte_Practica13_Arquitectura_Proyecto_Integrador.docx`](docs/Reporte_Practica13_Arquitectura_Proyecto_Integrador.docx).

---

## 🏗️ Diagrama de Arquitectura del Proyecto Integrador (Lab 2)

![Arquitectura de Referencia Azure Students](Lab%202/arquitectura-azure-students%20integradora.png)

### Matriz de Subredes y Direccionamiento IP (Lab 2)

| Recurso | Nombre Oficial (CAF - dev) | CIDR | Función / Propósito |
| :--- | :--- | :--- | :--- |
| **Red Virtual** | `vnet-utvt-integradora-dev-mxc-001` | `10.0.0.0/16` | Espacio de red privado unificado |
| **Integración App Service** | `snet-utvt-integradora-app-dev-mxc-001` | `10.0.1.0/24` | Delegada a `Microsoft.Web/serverFarms` |
| **Base de Datos (Reservada)** | `snet-utvt-integradora-db-dev-mxc-001` | `10.0.2.0/24` | Tráfico aislado de persistencia transaccional |
| **Máquina Virtual (Worker)** | `snet-utvt-integradora-vm-dev-mxc-001` | `10.0.3.0/24` | Procesamiento asíncrono y tareas batch |
| **Private Endpoints** | `snet-utvt-integradora-pe-dev-mxc-001` | `10.0.4.0/24` | `PrivateEndpointNetworkPolicies = Disabled` |
| **Azure Bastion Dedicado** | `AzureBastionSubnet` | `10.0.5.0/24` | Administración segura SSH/RDP sin IP pública |

---

## 📁 Estructura del Repositorio

```text
azure-laboratories/
├── .gitignore
├── README.md
├── app/
│   ├── index.html                      # Interfaz visual de prueba de la Web App
│   ├── package.json                    # Dependencias Node.js
│   └── server.js                       # Servidor Express instrumentado con Application Insights
├── docs/
│   ├── Reporte_Practica12_Azure_App_Service.docx               # Reporte formal Práctica 12
│   ├── Reporte_Practica13_Arquitectura_Proyecto_Integrador.docx # Reporte formal Práctica 13
│   ├── evidencias/                     # Capturas institucionales del Laboratorio 1
│   └── evidencias_lab2/                # Capturas de Portal y Terminal del Laboratorio 2
├── Lab 1/
│   ├── Componentes a crear.xlsx        # Matriz oficial de recursos para dev, qa y prod
│   ├── deploy-azure-resources.ps1      # Despliegue automatizado en PowerShell
│   ├── deploy-azure-resources.sh       # Despliegue automatizado en Bash
│   ├── main.tf                         # Infraestructura como Código (Terraform)
│   ├── variables.tf / outputs.tf       # Variables y salidas Terraform
│   ├── terraform.tfvars                # Valores de configuración
│   ├── arm-template.json               # Plantilla ARM nativa
│   └── bicep/main.bicep                # Plantilla Azure Bicep
└── Lab 2/
    ├── Red y subredes.xlsx              # Matriz oficial de diseño de red y direccionamiento
    ├── Creacion BD Integradora.txt     # Script oficial Azure CLI para creación de BD
    ├── arquitectura-azure-students integradora.png  # Diagrama de referencia Landing Zone
    ├── arquitectura-aws integradora.png             # Diagrama comparativo multicloud AWS
    ├── deploy-azure-resources.ps1      # Despliegue integral automatizado en PowerShell
    ├── deploy-azure-resources.sh       # Despliegue integral automatizado en Bash
    ├── manage-cost-optimization.ps1    # Script FinOps para parada/desasignación de cómputo
    ├── main.tf                         # Infraestructura completa en Terraform
    ├── variables.tf / outputs.tf       # Variables y salidas Terraform
    ├── terraform.tfvars                # Valores de variables para desarrollo
    ├── arm-template.json               # Plantilla ARM para el despliegue del Lab 2
    ├── bicep/main.bicep                # Plantilla declarativa en Azure Bicep
    └── README.md                       # Documentación técnica paso a paso del Lab 2
```

---

## 🚀 Despliegue Automatizado y Rutinas FinOps

### Despliegue de Infraestructura (Lab 2)
```powershell
cd "Lab 2"
.\deploy-azure-resources.ps1
```

### Rutina FinOps de Ahorro de Créditos (Azure for Students)
```powershell
# Detener VM y PostgreSQL al finalizar la sesión de laboratorio:
.\manage-cost-optimization.ps1 -Action Stop

# Reanudar servicios para pruebas:
.\manage-cost-optimization.ps1 -Action Start

# Consultar estado:
.\manage-cost-optimization.ps1 -Action Status
```

---

## 📄 Entregables Oficiales

1. **Código fuente:** Repositorio en GitHub [`LudwinGarcia1/azure-laboratories`](https://github.com/LudwinGarcia1/azure-laboratories) con historial de commits estructurado bajo estándar *Conventional Commits*.
2. **Reportes de evidencias:** 
   - Práctica 12: [`docs/Reporte_Practica12_Azure_App_Service.docx`](docs/Reporte_Practica12_Azure_App_Service.docx)
   - Práctica 13: [`docs/Reporte_Practica13_Arquitectura_Proyecto_Integrador.docx`](docs/Reporte_Practica13_Arquitectura_Proyecto_Integrador.docx) (con respaldo en `C:\Users\pingu\Documents\`).
