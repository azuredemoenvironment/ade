// Parameters
//////////////////////////////////////////////////
@description('The password of the admin user.')
@secure()
param adminPassword string

@description('The name of the admin user.')
param adminUserName string

@description('The ID of the Client Services Subnet.')
param clientServicesSubnetId string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The name of the Windows 10 Client Virtual Machine.')
param w10ClientName string

@description('The name of the Windows 10 Client NIC.')
param w10ClientNICName string

@description('The name of the Windows 10 Client operating system disk.')
param w10ClientOSDiskName string

@description('The private Ip address of the Windows 10 Client.')
param w10ClientPrivateIpAddress string

// Variables
//////////////////////////////////////////////////
var location = resourceGroup().location
var tags = {
  environment: 'production'
  function: 'clientServices'
  costCenter: 'it'
}

// Resource - Network Interface - W10client
//////////////////////////////////////////////////
resource w10ClientNIC 'Microsoft.Network/networkInterfaces@2020-08-01' = {
  name: w10ClientNICName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: w10ClientPrivateIpAddress
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: clientServicesSubnetId
          }
        }
      }
    ]
  }
}

// Resource - Network Interface - Diagnostic Settings - Jumpbox
//////////////////////////////////////////////////
resource w10ClientNICDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${w10ClientNIC.name}-diagnostics'
  scope: w10ClientNIC
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// Resource - Virtual Machine - W10client
//////////////////////////////////////////////////
resource w10Client 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: w10ClientName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    licenseType: 'Windows_Server'
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-10'
        sku: '21h1-pro'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: w10ClientOSDiskName
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: w10ClientName
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: w10ClientNIC.id
        }
      ]
    }
  }
}
