// parameters
param location string
param monitorResourceGroupName string
param logAnalyticsWorkspaceName string
param networkingResourceGroupName string
param virtualNetwork001Name string
param azureBastionPublicIpAddressName string
param azureBastionName string
param azureBastionSubnetId string

// variables
var environmentName = 'production'
var functionName = 'networking'
var costCenterName = 'it'

// existing resources
// log analytics
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(monitorResourceGroupName)
}
// virtual network
resource virtualNetwork001 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: virtualNetwork001Name
}

// resource - public ip address - azure bastion
resource azureBastionPublicIpAddress 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: azureBastionPublicIpAddressName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

// resource - public ip address - azure bastion - diagnostic settings
resource azureBastionPublicIpAddressDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${azureBastionPublicIpAddress.name}-diagnostics'
  scope: azureBastionPublicIpAddress
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'DDoSProtectionNotifications'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'DDoSMitigationFlowLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'DDoSMitigationReports'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
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

// resource - azure bastion
resource azureBastion 'Microsoft.Network/bastionHosts@2020-07-01' = {
  name: azureBastionName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipConf'
        properties: {
          publicIPAddress: {
            id: azureBastionPublicIpAddress.id
          }
          subnet: {
            id: azureBastionSubnetId
          }
        }
      }
    ]
  }
}

// resource - azure bastion - diagnostic settings
resource azureBastionDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${azureBastion.name}-diagnostics'
  scope: azureBastion
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'BastionAuditLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}