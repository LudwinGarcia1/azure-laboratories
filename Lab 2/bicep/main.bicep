@description('Región de Azure para los recursos')
param location string = 'mexicocentral'

@description('Nombre de la Red Virtual')
param vnetName string = 'vnet-utvt-integradora-dev-mxc-001'

@description('Nombre de la Máquina Virtual')
param vmName string = 'vm-utvt-integradora-dev-mxc-001'

@description('Usuario administrador')
param adminUsername string = 'azureuser'

@description('Contraseña de administrador')
@secure()
param adminPassword string = 'Utvt2026@PasswordSeguro!'

@description('Servidor PostgreSQL Flexible')
param postgresServerName string = 'psql-utvt-integradora-dev-mxc-001'

@description('Cuenta de almacenamiento')
param storageAccountName string = 'stutvtintdevmxc001'

@description('App Service Plan')
param appServicePlanName string = 'asp-utvt-integradora-dev-mxc-001'

@description('Nombre de la aplicación Web')
param webAppName string = 'app-utvt-integradora-web-dev-mxc-001'

var tags = {
  Environment: 'dev'
  Project: 'Restaurant Hub (RestoHub) / Callejón 9'
  Materia: 'Arquitectura del Proyecto Integrador'
  Institucion: 'Universidad Tecnológica del Valle de Toluca (UTVT)'
  Carrera: 'Ingeniería en Desarrollo y Gestión de Software'
  Grupo: 'IDGS 101'
  Alumno: 'Ludwin García Gaytán'
  Matricula: '222310777'
}

// 1. Red Virtual y Subredes
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-utvt-integradora-app-dev-mxc-001'
        properties: {
          addressPrefix: '10.0.1.0/24'
          delegations: [
            {
              name: 'delegation-appservice'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: 'snet-utvt-integradora-db-dev-mxc-001'
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
      {
        name: 'snet-utvt-integradora-vm-dev-mxc-001'
        properties: {
          addressPrefix: '10.0.3.0/24'
        }
      }
      {
        name: 'snet-utvt-integradora-pe-dev-mxc-001'
        properties: {
          addressPrefix: '10.0.4.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.5.0/24'
        }
      }
    ]
  }
}

// 2. Network Interface y Máquina Virtual Linux
resource nicVm 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'nic-utvt-integradora-vm-dev-mxc-001'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'snet-utvt-integradora-vm-dev-mxc-001')
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
  dependsOn: [
    vnet
  ]
}

resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ats_v2'
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
    }
    osProfile: {
      computerName: 'vmworker'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicVm.id
        }
      ]
    }
  }
}

// 3. PostgreSQL Flexible Server y Base de Datos
resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2023-03-01-preview' = {
  name: postgresServerName
  location: location
  tags: tags
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  properties: {
    version: '16'
    administratorLogin: adminUsername
    administratorLoginPassword: adminPassword
    storage: {
      storageSizeGB: 32
    }
    network: {
      publicNetworkAccess: 'Disabled'
    }
  }
}

resource postgresDb 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2023-03-01-preview' = {
  parent: postgresServer
  name: 'integradora'
  properties: {
    charset: 'UTF8'
    collation: 'en_US.utf8'
  }
}

// 4. Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: 'Disabled'
  }
}

// 5. App Service Plan y Web App con VNet Integration
resource appPlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  kind: 'linux'
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  properties: {
    reserved: true
  }
}

resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: webAppName
  location: location
  tags: tags
  properties: {
    serverFarmId: appPlan.id
    virtualNetworkSubnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'snet-utvt-integradora-app-dev-mxc-001')
    siteConfig: {
      linuxFxVersion: 'NODE|20-lts'
      alwaysOn: true
    }
  }
  dependsOn: [
    vnet
  ]
}

output vnetId string = vnet.id
output webAppEndpoint string = webApp.properties.defaultHostName
