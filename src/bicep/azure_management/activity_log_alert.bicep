// Parameters
//////////////////////////////////////////////////
@description('The array of Activity Log Alerts.')
param activityLogAlerts array

@description('The list of resource tags.')
param tags object

// Resource - Activity Log Alert
//////////////////////////////////////////////////
resource alert 'Microsoft.Insights/activityLogAlerts@2020-10-01' = [for (activityLogAlert, i) in activityLogAlerts: {
  name: activityLogAlert.name
  location: 'global'
  tags: tags
  properties: {
    description: activityLogAlert.name
    enabled: activityLogAlert.enabled
    scopes: activityLogAlert.scopes
    condition: activityLogAlert.condition
    actions: activityLogAlert.actions
  }
}]
