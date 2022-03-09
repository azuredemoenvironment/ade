// Parameters
//////////////////////////////////////////////////
@description('The name of the Azure Bastion')
param azureBastionName string

@description('The name of the Azure Bastion Public IP Address.')
param azureBastionPublicIpAddressName string

@description('The ID of the Azure Bastion Subnet.')
param azureBastionSubnetId string

@description('The ID of the Diagnostics Storage Account.')
param diagnosticsStorageAccountId string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

// Variables
//////////////////////////////////////////////////
var location = resourceGroup().location
var tags = {
  environment: 'production'
  function: 'networking'
  costCenter: 'it'
}

// Resource - Public Ip Address
//////////////////////////////////////////////////
resource azureBastionPublicIpAddress 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: azureBastionPublicIpAddressName
  location: location
  tags: tags
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

// Resource - Public Ip Address - Diagnostic Settings
//////////////////////////////////////////////////
resource azureBastionPublicIpAddressDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: azureBastionPublicIpAddress
  name: '${azureBastionPublicIpAddress.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'DDoSProtectionNotifications'
        enabled: true
      }
      {
        category: 'DDoSMitigationFlowLogs'
        enabled: true
      }
      {
        category: 'DDoSMitigationReports'
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

// Resource - Azure Bastion
//////////////////////////////////////////////////
resource azureBastion 'Microsoft.Network/bastionHosts@2020-07-01' = {
  name: azureBastionName
  location: location
  tags: tags
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

// Resource - Azure Bastion - Diagnostic Settings
//////////////////////////////////////////////////
resource azureBastionDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: azureBastion
  name: '${azureBastion.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'BastionAuditLogs'
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
