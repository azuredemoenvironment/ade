// parameters
param location string
param adminUserName string
param adminPassword string
param monitorResourceGroupName string
param logAnalyticsWorkspaceName string
param networkingResourceGroupName string
param virtualNetwork002Name string
param clientServicesSubnetName string
param w10ClientNICName string
param w10ClientPrivateIpAddress string
param w10ClientName string
param w10ClientOSDiskName string

// variables
var environmentName = 'production'
var functionName = 'clientServices'
var costCenterName = 'it'

// existing resources
// log analytics
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(monitorResourceGroupName)
}
// virtual network - virtual network 002
resource virtualNetwork002 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  name: virtualNetwork002Name
  scope: resourceGroup(networkingResourceGroupName)
  resource clientServicesSubnet 'subnets@2020-07-01' existing = {
    name: clientServicesSubnetName
  }
}

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
            id: virtualNetwork002::clientServicesSubnet.id
          }
        }
      }
    ]
  }
}

// resource - network interface - jumpbox - diagnostic settings
resource w10ClientNICDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${w10ClientNIC.name}-diagnostics'
  scope: w10ClientNIC
  properties: {
    workspaceId: logAnalyticsWorkspace.id
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
        sku: 'rs5-pro'
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
