// Parameters
//////////////////////////////////////////////////
@description('The properties of the Application Insights instance.')
param applicationInsightsProperties object

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

// Resource - Application Insights
//////////////////////////////////////////////////
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsProperties.name
  location: location
  tags: tags
  kind: applicationInsightsProperties.kind
  properties: {
    Application_Type: applicationInsightsProperties.properties.Application_Type
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}

// Resource - Application Insights - Diagnostic Settings
//////////////////////////////////////////////////
resource applicationInsightsDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: applicationInsights
  name: '${applicationInsights.name}-diagnostics'
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
          enabled: true
          days: 7
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
    ]
  }
}

// Outputs
//////////////////////////////////////////////////
output applicationInsightsConnectionString string = applicationInsights.properties.ConnectionString
