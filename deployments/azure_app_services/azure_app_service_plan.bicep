// Parameters
//////////////////////////////////////////////////
@description('The name of the App Service Plan.')
param appServicePlanName string

@description('The region location of deployment.')
param location string = resourceGroup().location

// Variables
//////////////////////////////////////////////////
var tags = {
  environment: 'production'
  function: 'appServicePlan'
  costCenter: 'it'
}

// Resource - App Service Plan
//////////////////////////////////////////////////
resource appServicePlan 'Microsoft.Web/serverfarms@2020-10-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  kind: 'linux'
  sku: {
    name: 'P1v3'
  }
  properties: {
    reserved: true
  }
}

// Resource - App Service Plan - Autoscale Setting
//////////////////////////////////////////////////
resource autoscaleSetting 'Microsoft.insights/autoscalesettings@2015-04-01' = {
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
