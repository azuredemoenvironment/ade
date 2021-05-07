// parameters
param location string
param aliasRegion string
param appServiceAppName string

// variables
var appServiceName = 'app-ade-${aliasRegion}-${appServiceAppName}'
var environmentName = 'production'
var functionName = 'appServicePlan'
var costCenterName = 'it'

// existing resource - log analytics
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(monitorResourceGroupName)
}

// existing resource - app service plan
var appServicePlanResourceGroupName = 'rg-ade-${aliasRegion}-appserviceplan'
var appServicePlanName = 'plan-ade-${aliasRegion}-001'
resource appServicePlan 'Microsoft.Web/serverfarms@2020-10-01' existing = {
  name: appServicePlanName
  scope: resourceGroup(appServicePlanResourceGroupName)
}

// resource - App Service
resource appService 'Microsoft.Web/sites@2020-10-01' = {
  name: appServiceName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: false
    siteConfig: {
      appSettings: [
        {
          name: 'TEST'
          value: 'test'
        }
      ]
    }
  }
}

resource appServiceDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${appService.name}-diagnostics'
  scope: appService
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AppServiceConsoleLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AppServiceAppLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AppServiceFileAuditLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AppServiceAuditLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AppServiceIPSecAuditLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AppServicePlatformLogs'
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
