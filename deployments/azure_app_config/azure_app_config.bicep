// parameters
param location string = resourceGroup().location
param aliasRegion string

// variables
var appConfigName = 'appcs-ade-${aliasRegion}-001'
var environmentName = 'production'
var functionName = 'app config'
var costCenterName = 'it'

// existing resources
// log analytics workspace
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: logAnalyticsWorkspaceName
}

resource appConfig 'Microsoft.AppConfiguration/configurationStores@2021-03-01-preview' = {
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
    workspaceId: logAnalyticsWorkspace.id
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
