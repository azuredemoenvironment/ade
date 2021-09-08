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

// variables
var applicationInsightsName = 'appinsights-ade-${aliasRegion}-001'
// resource
resource applicationInsights 'Microsoft.Insights/components@2020-02-02-preview' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: applicationInsightsName
}

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

// resource - app config - key value pairs
var appConfigKeyValuePairs = [
  {
    key: 'AppInsights:ConnectionString'
    // value: applicationInsights.properties.ConnectionString
    value: 'tbd'
  }
  {
    key: 'AppInsights:InstrumentationKey'
    // value: applicationInsights.properties.InstrumentationKey
    value: 'tbd'
  }
  {
    key: 'ADE:SqlServerConnectionString'
    value: 'tbd'
  }
  {
    key: 'ADE:ApiGatewayUri'
    value: 'tbd'
  }
]

resource appConfigKeys 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = [for appConfigKeyValuePair in appConfigKeyValuePairs: {
  name: '${appConfig.name}/${appConfigKeyValuePair.key}'
  properties: {
    value: appConfigKeyValuePair.value
  }
}]
