// parameters
param location string = resourceGroup().location
param appConfigName string
param logAnalyticsWorkspaceId string

// variables
var environmentName = 'production'
var functionName = 'app config'
var costCenterName = 'it'

// new resources
// resource - app configuration service
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2020-07-01-preview' = {
  name: appConfigName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  sku: {
    name: 'Standard'
  }
}

// resource - app config - diagnostic settings
resource appConfigDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
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

resource appConfigKeyAspNetCoreEnvironment 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  name: '${appConfig.name}/ASPNETCORE_ENVIRONMENT'
  properties: {
    value: 'Development'
  }
}

output appConfigName string = appConfig.name
