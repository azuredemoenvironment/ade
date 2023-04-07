// Parameters
//////////////////////////////////////////////////
@description('The name of the Bastion')
param bastionName string

@description('The ID of the Bastion Subnet.')
param bastionSubnetId string

@description('The ID of the Diagnostics Storage Account.')
param storageAccountId string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

// @description('The name of the Firewall Public IP Address.')
// param publicIpAddressName string

@description('The properties of the Public IP Address')
param publicIpAddressProperties object

@description('The list of resource tags')
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
resource publicIpAddressDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
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

// Resource - Bastion
//////////////////////////////////////////////////
resource bastion 'Microsoft.Network/bastionHosts@2022-09-01' = {
  name: bastionName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipConf'
        properties: {
          publicIPAddress: {
            id: publicIpAddress.id
          }
          subnet: {
            id: bastionSubnetId
          }
        }
      }
    ]
  }
}

// Resource - Bastion - Diagnostic Settings
//////////////////////////////////////////////////
resource bastionDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: bastion
  name: '${bastion.name}-diagnostics'
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
