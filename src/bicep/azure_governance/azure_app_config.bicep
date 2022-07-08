// Parameters
//////////////////////////////////////////////////
@description('The name of the App Configuration.')
param appConfigName string

@description('The ID of the Diagnostics Storage Account.')
param diagnosticsStorageAccountId string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

// Variables
//////////////////////////////////////////////////
var tags = {
  environment: 'production'
  function: 'app config'
  costCenter: 'it'
}

// Resource - App Configuration
//////////////////////////////////////////////////
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2022-05-01' = {
  name: appConfigName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    createMode: 'Default'
    enablePurgeProtection: false
  }
}

// Resource - App Configuration - Diagnostic Settings
//////////////////////////////////////////////////
resource appConfigDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: appConfig
  name: '${appConfig.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'HttpRequest'
        enabled: true
      }
      {
        category: 'Audit'
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

// Resource - App Configuration - ASP.NET Core Environment
//////////////////////////////////////////////////
resource appConfigKeyAspNetCoreEnvironment 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  name: '${appConfig.name}/ASPNETCORE_ENVIRONMENT'
  properties: {
    value: 'Development'
  }
}

// Outputs
//////////////////////////////////////////////////
output appConfigName string = appConfig.name
