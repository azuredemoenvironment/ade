// parameters
param location string
param monitorResourceGroupName string
param logAnalyticsWorkspaceName string
param virtualNetwork001Name string
param virtualnetwork001Prefix string
param azureFirewallSubnetName string
param azureFirewallSubnetPrefix string
param applicationGatewaySubnetName string
param applicationGatewaySubnetPrefix string
param azureBastionSubnetName string
param azureBastionSubnetPrefix string
param managementSubnetName string
param managementSubnetPrefix string
param gatewaySubnetName string
param gatewaySubnetPrefix string
param azureBastionSubnetNSGId string
param managementSubnetNSGId string

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

// resource - virtual network 001
resource virtualNetwork001 'Microsoft.Network/virtualNetworks@2020-07-01' = {
  name: virtualNetwork001Name
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualnetwork001Prefix
      ]
    }
    subnets: [
      {
        name: azureFirewallSubnetName
        properties: {
          addressPrefix: azureFirewallSubnetPrefix
        }
      }
      {
        name: applicationGatewaySubnetName
        properties: {
          addressPrefix: applicationGatewaySubnetPrefix
          serviceEndpoints: [
            {
              service: 'Microsoft.Web'
            }
          ]
        }
      }
      {
        name: azureBastionSubnetName
        properties: {
          addressPrefix: azureBastionSubnetPrefix
          networkSecurityGroup: {
            id: azureBastionSubnetNSGId
          }
        }
      }
      {
        name: managementSubnetName
        properties: {
          addressPrefix: managementSubnetPrefix
          networkSecurityGroup: {
            id: managementSubnetNSGId
          }
        }
      }
      {
        name: gatewaySubnetName
        properties: {
          addressPrefix: gatewaySubnetPrefix
        }
      }
    ]
  }
}

// resource - virtual network 001 - diagnostic settings
resource virtualNetwork001Diagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${virtualNetwork001.name}-diagnostics'
  scope: virtualNetwork001
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'VMProtectionAlerts'
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

output virtualNetwork001Id string = virtualNetwork001.id
output azureFirewallSubnetId string = virtualNetwork001.properties.subnets[0].id
output azureBastionSubnetId string = virtualNetwork001.properties.subnets[2].id
output gatewaySubnetId string = virtualNetwork001.properties.subnets[4].id