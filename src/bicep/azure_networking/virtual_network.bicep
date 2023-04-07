// Parameters
//////////////////////////////////////////////////
@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The name of hub Virtual Network.')
param hubVirtualNetworkName string

@description('The address prefix of hub Virtual Network.')
param hubVirtualNetworkPrefix string

@description('The array of properties for Virtual Networks 001 Subnets.')
param hubVirtualNetworkSubnets array

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The name of Virtual Network 002.')
param spokeVirtualNetworkName string

@description('The address prefix of Virtual Network 002.')
param spokeVirtualNetworkPrefix string

@description('The array of properties for Virtual Networks 002 Subnets.')
param spokeVirtualNetworkSubnets array

@description('The ID of the Storage Account.')
param storageAccountId string

@description('The list of resource tags.')
param tags object

// Resource - Virtual Network - Hub
//////////////////////////////////////////////////
resource hubVirtualNetwork 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: hubVirtualNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        hubVirtualNetworkPrefix
      ]
    }
    subnets: [for subnet in hubVirtualNetworkSubnets: {
      name: subnet.name
      properties: subnet.properties
    }]
  }
  resource bastionSubnet 'subnets' existing = {
    name: 'AzureBastionSubnet'
  }
  resource firewallSubnet 'subnets' existing = {
    name: 'AzureFirewallSubnet'
  }
  resource gatewaySubnet 'subnets' existing = {
    name: 'GatewaySubnet'
  }
}

// Resource - Virtual Network - Hub - Diagnostic Settings
//////////////////////////////////////////////////
resource hubVirtualNetworkDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: hubVirtualNetwork
  name: '${hubVirtualNetwork.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: storageAccountId
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

// Resource - Virtual Network - Spoke
//////////////////////////////////////////////////
resource spokeVirtualNetwork 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: spokeVirtualNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        spokeVirtualNetworkPrefix
      ]
    }
    subnets: [for subnet in spokeVirtualNetworkSubnets: {
      name: subnet.name
      properties: subnet.properties
    }]
  }
}

// Resource - Virtual Network - Spoke - Diagnostic Settings
//////////////////////////////////////////////////
resource spokeVirtualNetworkDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: spokeVirtualNetwork
  name: '${spokeVirtualNetwork.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: storageAccountId
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
output bastionSubnetId string = hubVirtualNetwork::bastionSubnet.id
output firewallSubnetId string = hubVirtualNetwork::firewallSubnet.id
output gatewaySubnetId string = hubVirtualNetwork::gatewaySubnet.id
output hubVirtualNetworkId string = hubVirtualNetwork.id
output spokeVirtualNetworkId string = spokeVirtualNetwork.id
