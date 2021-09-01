// Target Scope - This option sets the scope of the deployment to the subscription.
targetScope = 'subscription'

// Parameters
@description('Parameter for the resource ID of the Log Analytics Workspace. Defined in azure_governance.bicep.')
param logAnalyticsWorkspaceId string

// Resource - Subscription Activity Log - Diagnostic Settings
resource subscriptionActivityLog 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  name: 'subscriptionactivitylog'
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
