// Parameters
//////////////////////////////////////////////////
@description('The ID of the Diagnostics Storage Account.')
param diagnosticsStorageAccountId string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The list of Resource tags')
param tags object

@description('The name of Virtual Network 001.')
param virtualNetwork001Name string

@description('The address prefix of Virtual Network 001.')
param virtualNetwork001Prefix string

@description('The array of properties for Virtual Networks 001 Subnets.')
param virtualNetwork001Subnets array

@description('The name of Virtual Network 002.')
param virtualNetwork002Name string

@description('The address prefix of Virtual Network 002.')
param virtualNetwork002Prefix string

@description('The array of properties for Virtual Networks 002 Subnets.')
param virtualNetwork002Subnets array

// Resource - Virtual Network 001
//////////////////////////////////////////////////
resource virtualNetwork001 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: virtualNetwork001Name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetwork001Prefix
      ]
    }
    subnets: [for subnet in virtualNetwork001Subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.subnetPrefix
        natGateway: subnet.natGatewayId != null ? {
          id: subnet.natGatewayId
        } : null
        networkSecurityGroup: subnet.networkSecurityGroupId != null ? {
          id: subnet.networkSecurityGroupId
        } : null
        privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies != null ? subnet.privateEndpointNetworkPolicies : null
        serviceEndpoints: subnet.serviceEndpoints != null ? subnet.serviceEndpoints : null
      }
    }]
  }
  resource azureBastionSubnet 'subnets' existing = {
    name: 'AzureBastionSubnet'
  }
  resource azureFirewallSubnet 'subnets' existing = {
    name: 'AzureFirewallSubnet'
  }
  resource gatewaySubnet 'subnets' existing = {
    name: 'GatewaySubnet'
  }
}

// Resource - Virtual Network 001 - Diagnostic Settings
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

// Resource - Virtual Network 002
//////////////////////////////////////////////////
resource virtualNetwork002 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: virtualNetwork002Name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetwork002Prefix
      ]
    }
    subnets: [for subnet in virtualNetwork002Subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.subnetPrefix
        natGateway: subnet.natGatewayId != null ? {
          id: subnet.natGatewayId
        } : null
        networkSecurityGroup: subnet.networkSecurityGroupId != null ? {
          id: subnet.networkSecurityGroupId
        } : null
        privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies != null ? subnet.privateEndpointNetworkPolicies : null
        serviceEndpoints: subnet.serviceEndpoints != null ? subnet.serviceEndpoints : null
      }
    }]
  }
}

// Resource - Virtual Network 002 - Diagnostic Settings
//////////////////////////////////////////////////
resource virtualNetwork002Diagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: virtualNetwork002
  name: '${virtualNetwork002.name}-diagnostics'
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
output virtualNetwork002Id string = virtualNetwork002.id
