// Parameters
//////////////////////////////////////////////////
@description('The name of the Application Gateway Subnet.')
param applicationGatewaySubnetName string

@description('The ID of the Application Gateway Subnet NSG.')
param applicationGatewaySubnetNSGId string

@description('The address prefix of the Application Gateway Subnet.')
param applicationGatewaySubnetPrefix string

@description('The name of the Azure Bastion Subnet.')
param azureBastionSubnetName string

@description('The ID of the Azure Bastion Subnet NSG.')
param azureBastionSubnetNSGId string

@description('The address prefix of the Azure Bastion Subnet.')
param azureBastionSubnetPrefix string

@description('The name of the Azure Firewall Subnet.')
param azureFirewallSubnetName string

@description('The address prefix of the Azure Firewall Subnet.')
param azureFirewallSubnetPrefix string

@description('The ID of the Diagnostics Storage Account.')
param diagnosticsStorageAccountId string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The name of the Gateway Subnet.')
param gatewaySubnetName string

@description('The address prefix of the Gateway Subnet.')
param gatewaySubnetPrefix string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The name of the Management Subnet.')
param managementSubnetName string

@description('The ID of the Management Subnet NSG.')
param managementSubnetNSGId string

@description('The address prefix of the Management Subnet.')
param managementSubnetPrefix string

@description('The name of the Virtual Network.')
param virtualNetwork001Name string

@description('The address prefix of the Virtual Network.')
param virtualnetwork001Prefix string

// Variables
//////////////////////////////////////////////////
var tags = {
  environment: 'production'
  function: 'networking'
  costCenter: 'it'
}

// Resource - Virtual Network
//////////////////////////////////////////////////
resource virtualNetwork001 'Microsoft.Network/virtualNetworks@2020-07-01' = {
  name: virtualNetwork001Name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualnetwork001Prefix
      ]
    }
    subnets: [
      {
        name: applicationGatewaySubnetName
        properties: {
          addressPrefix: applicationGatewaySubnetPrefix
          networkSecurityGroup: {
            id: applicationGatewaySubnetNSGId
          }
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
        name: azureFirewallSubnetName
        properties: {
          addressPrefix: azureFirewallSubnetPrefix
        }
      }
      {
        name: gatewaySubnetName
        properties: {
          addressPrefix: gatewaySubnetPrefix
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
    ]
  }
  resource applicationGatewaySubnet 'subnets' existing = {
    name: applicationGatewaySubnetName
  }
  resource azureBastionSubnet 'subnets' existing = {
    name: azureBastionSubnetName
  }
  resource azureFirewallSubnet 'subnets' existing = {
    name: azureFirewallSubnetName
  }
  resource gatewaySubnet 'subnets' existing = {
    name: gatewaySubnetName
  }
  resource managementSubnet 'subnets' existing = {
    name: managementSubnetName
  }
}

// Resource - Virtual Network - Diagnostic Settings
//////////////////////////////////////////////////
resource virtualNetwork001Diagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: virtualNetwork001
  name: '${virtualNetwork001.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'VMProtectionAlerts'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// Outputs
//////////////////////////////////////////////////
output azureBastionSubnetId string = virtualNetwork001::azureBastionSubnet.id
output azureFirewallSubnetId string = virtualNetwork001::azureFirewallSubnet.id
output gatewaySubnetId string = virtualNetwork001::gatewaySubnet.id
output virtualNetwork001Id string = virtualNetwork001.id
