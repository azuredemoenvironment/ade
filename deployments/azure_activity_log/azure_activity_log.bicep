// target scope
targetScope = 'subscription'

// variables
var diagnosticSettingsName = 'subscriptionactivitylog'

// existing resources
// log analytics
param logAnalyticsWorkspaceResourceGroupName string
param logAnalyticsWorkspaceName string
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(logAnalyticsWorkspaceResourceGroupName)
}

// resource - subscription activity log - diagnostic settings
resource subscriptionActivityLog 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  name: diagnosticSettingsName
  properties: {
    workspaceId: logAnalyticsWorkspace.id
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