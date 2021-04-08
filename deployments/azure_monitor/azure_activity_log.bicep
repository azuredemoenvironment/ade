// target scope
targetScope = 'subscription'

// parameters
param logAnalyticsWorkspaceId string

// variables
var diagnosticSettingsName = 'subscriptionactivitylog'

// resource - subscription activity log - diagnostic settings
resource subscriptionActivityLog 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  name: diagnosticSettingsName
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
