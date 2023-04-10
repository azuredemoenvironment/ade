// Parameters
//////////////////////////////////////////////////
@description('The properties of the App Service Plan.')
param appServicePlanProperties object

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

// Resource - App Service Plan
//////////////////////////////////////////////////
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanProperties.name
  location: location
  tags: tags
  kind: appServicePlanProperties.kind
  sku: {
    name: appServicePlanProperties.skuName
  }
  properties: {
    reserved: appServicePlanProperties.reserved
  }
}

// Resource - App Service Plan - Diagnostic Settings
//////////////////////////////////////////////////
resource appServicePlanDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: appServicePlan
  name: '${appServicePlan.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: storageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// Resource - App Service Plan - Autoscale Setting
//////////////////////////////////////////////////
resource autoscaleSetting 'Microsoft.Insights/autoscalesettings@2021-05-01-preview' = {
  name: '${appServicePlan.name}-autoscale'
  location: location
  tags: tags
  properties: {
    name: '${appServicePlan.name}-autoscale'
    enabled: true
    targetResourceUri: appServicePlan.id
    profiles: [
      {
        name: 'defaultAutoscaleProfile'
        capacity: {
          minimum: '1'
          maximum: '10'
          default: '1'
        }
        rules: [
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricNamespace: 'Microsoft.Web/serverfarms'
              metricResourceUri: appServicePlan.id
              timeGrain: 'PT1M'
              timeWindow: 'PT5M'
              timeAggregation: 'Maximum'
              statistic: 'Max'
              operator: 'GreaterThan'
              threshold: 70
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '2'
              cooldown: 'PT5M'
            }
          }
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricNamespace: 'Microsoft.Web/serverfarms'
              metricResourceUri: appServicePlan.id
              timeGrain: 'PT1M'
              timeWindow: 'PT5M'
              timeAggregation: 'Maximum'
              statistic: 'Max'
              operator: 'LessThan'
              threshold: 40
            }
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
          }
        ]
      }
    ]
  }
}

// Outputs
//////////////////////////////////////////////////
output appServicePlanId string = appServicePlan.id
