// parameters
param location string
param adminUserName string
param adminPassword string
param logAnalyticsWorkspaceId string
param clientServicesSubnetId string
param w10ClientNICName string
param w10ClientPrivateIpAddress string
param w10ClientName string
param w10ClientOSDiskName string

// variables
var environmentName = 'production'
var functionName = 'clientServices'
var costCenterName = 'it'

// resource - network interface - w10client
resource w10ClientNIC 'Microsoft.Network/networkInterfaces@2020-08-01' = {
  name: w10ClientNICName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
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

// resource - network interface - diagnostic settings - jumpbox
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

// resource - virtual machine - w10client
resource w10Client 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: w10ClientName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
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
