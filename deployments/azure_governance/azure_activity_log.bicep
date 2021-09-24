// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'

// Parameters
//////////////////////////////////////////////////
@description('The name of the Activity Log Diagnostic Settings.')
param activityLogDiagnosticSettingsName string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

// Resource - Subscription Activity Log - Diagnostic Settings
//////////////////////////////////////////////////
resource subscriptionActivityLog 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: activityLogDiagnosticSettingsName
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'Administrative'
        enabled: true
      }
      {
        category: 'Security'
        enabled: true
      }
      {
        category: 'ServiceHealth'
        enabled: true
      }
      {
        category: 'Alert'
        enabled: true
      }
      {
        category: 'Recommendation'
        enabled: true
      }
      {
        category: 'Policy'
        enabled: true
      }
      {
        category: 'Autoscale'
        enabled: true
      }
      {
        category: 'ResourceHealth'
        enabled: true
      }
    ]
  }
}
