// Parameters
//////////////////////////////////////////////////
@description('The name of the App Configuration.')
param appConfigName string

@description('The region location of deployment.')
param location string = resourceGroup().location

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
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2020-07-01-preview' = {
  name: appConfigName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
}

// Resource - App Configuration - Diagnostic Settings
//////////////////////////////////////////////////
resource appConfigDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: appConfig
  name: '${appConfig.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'HttpRequest'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'Audit'
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

// Resource - App Configuration - ASP.NET Core Environment
//////////////////////////////////////////////////
resource appConfigKeyAspNetCoreEnvironment 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  name: '${appConfig.name}/ASPNETCORE_ENVIRONMENT'
  properties: {
    value: 'Development'
  }
}

// Outpus
//////////////////////////////////////////////////
output appConfigName string = appConfig.name
