// Parameters
@description('Parameter for the location of resources. Defined in azure_governance.bicep.')
param location string

@description('Parameter for the name of the Application Insights instance. Defined in azure_governance.bicep.')
param applicationInsightsName string

@description('Parameter for the resource ID of the Log Analytics Workspace. Defined in azure_governance.bicep.')
param logAnalyticsWorkspaceId string

// Variables
var environmentName = 'production'
var functionName = 'monitoring and diagnostics'
var costCenterName = 'it'

// Resource - Application Insights
resource applicationInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: applicationInsightsName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}

// Resource - Application Insights - Diagnostic Settings
resource applicationInsightsDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: applicationInsights
  name: '${applicationInsights.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'AppAvailabilityResults'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AppBrowserTimings'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AppEvents'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AppMetrics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AppDependencies'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AppExceptions'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AppPageViews'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AppPerformanceCounters'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AppRequests'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AppSystemEvents'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AppTraces'
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
