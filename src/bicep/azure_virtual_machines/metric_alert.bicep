// Parameters
//////////////////////////////////////////////////
@description('The properties of the Metric')
param metricAlertProperties object

@description('The list of resource tags.')
param tags object

// Resource - Metric Alert
//////////////////////////////////////////////////
resource alert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: metricAlertProperties.name
  location: 'global'
  tags: tags
  properties: {
    description: metricAlertProperties.name    
    enabled: metricAlertProperties.enabled
    scopes: metricAlertProperties.scopes    
    severity: metricAlertProperties.severity
    evaluationFrequency: metricAlertProperties.evaluationFrequency
    windowSize: metricAlertProperties.windowSize
    targetResourceType: metricAlertProperties.targetResourceType
    targetResourceRegion: metricAlertProperties.targetResourceRegion
    criteria: metricAlertProperties.criteria
    actions: metricAlertProperties.actions
  }
}
