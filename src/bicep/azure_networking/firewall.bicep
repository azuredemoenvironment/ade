// Parameters
//////////////////////////////////////////////////
@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

// @description('The name of the Firewall.')
// param firewallName string

@description('The properties of the Firewall.')
param firewallProperties object

@description('The ID of the Firewall Subnet.')
param firewallSubnetId string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

// @description('The name of the Firewall Public IP Address.')
// param publicIpAddressName string

@description('The properties of the Public IP Address.')
param publicIpAddressProperties object

@description('The ID of the Storage Account.')
param storageAccountId string

@description('The list of resource tags.')
param tags object

// Resource - Public Ip Address
//////////////////////////////////////////////////
resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-09-01' = {
  name: publicIpAddressProperties.name
  location: location
  tags: tags
  properties: {
    publicIPAllocationMethod: publicIpAddressProperties.publicIPAllocationMethod
    publicIPAddressVersion: publicIpAddressProperties.publicIPAddressVersion
  }
  sku: {
    name: publicIpAddressProperties.sku
  }
}

// Resource - Public Ip Address - Diagnostic Settings
//////////////////////////////////////////////////
resource publicIpAddressDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: publicIpAddress
  name: '${publicIpAddress.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: storageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        categoryGroup: 'allLogs'
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

// Resource - Firewall
//////////////////////////////////////////////////
resource firewall 'Microsoft.Network/azureFirewalls@2022-09-01' = {
  name: firewallProperties.name
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          publicIPAddress: {
            id: publicIpAddress.id
          }
          subnet: {
            id: firewallSubnetId
          }
        }
      }
    ]
    applicationRuleCollections: []
  }
}

// Resource - Firewall - Diagnostic Settings
//////////////////////////////////////////////////
resource firewallDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: firewall
  name: '${firewall.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: storageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        categoryGroup: 'allLogs'
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
