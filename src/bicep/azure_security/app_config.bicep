// Parameters
//////////////////////////////////////////////////
@description('The name of the App Configuration.')
param appConfigName string

@description('The purge protection setting of the App Configuration.')
param appConfigPurgeProtection bool

@description('The sku of the App Configuration.')
param appConfigSku string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The ID of the Storage Account.')
param storageAccountId string

@description('The list of resource tags.')
param tags object

// Resource - App Configuration
//////////////////////////////////////////////////
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = {
  name: appConfigName
  location: location
  tags: tags
  sku: {
    name: appConfigSku
  }
  properties: {
    createMode: 'Default'
    enablePurgeProtection: appConfigPurgeProtection
  }
}

// Resource - App Configuration - Diagnostic Settings
//////////////////////////////////////////////////
resource appConfigDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: appConfig
  name: '${appConfig.name}-diagnostics'
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

// Outputs
//////////////////////////////////////////////////
output appConfigName string = appConfig.name
