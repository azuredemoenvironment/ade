// Parameters
//////////////////////////////////////////////////
@description('The selected Azure region for deployment.')
param azureRegion string

@description('The ID of the Service Health Action Group.')
param serviceHealthActionGroupId string

@description('The name of the Service Health Alert.')
param serviceHealthAlertName string

@description('The list of resource tags.')
param tags object

@description('The ID of the Virtual Machine Action Group.')
param virtualMachineActionGroupId string

@description('The name of the Virtual Machine Administrative Alert.')
param virtualMachineAlertName string

@description('The name of the Virtual Machine CPU Metric Alert.')
param virtualMachineCpuAlertName string

@description('The ID of the Virtual Network Action Group.')
param virtualNetworkActionGroupId string

@description('The name of the Virtual Network Alert.')
param virtualNetworkAlertName string

// Resource - Alert - Service Health
//////////////////////////////////////////////////
resource serviceHealthAlert 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: serviceHealthAlertName
  location: 'global'
  tags: tags
  properties: {
    description: serviceHealthAlertName
    enabled: false
    scopes: [
      subscription().id
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'ServiceHealth'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: serviceHealthActionGroupId
        }
      ]
    }
  }
}

// Resource - Alert - Virtual Machine
//////////////////////////////////////////////////
resource virtualMachineAlert 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: virtualMachineAlertName
  location: 'global'
  tags: tags
  properties: {
    description: virtualMachineAlertName
    enabled: false
    scopes: [
      subscription().id
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'ServiceHealth'
        }
        {
          field: 'resourceType'
          equals: 'microsoft.compute/virtualmachines'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: virtualMachineActionGroupId
        }
      ]
    }
  }
}

// Resource - Alert - Virtual Network
//////////////////////////////////////////////////
resource virtualNetworkAlert 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: virtualNetworkAlertName
  location: 'global'
  tags: tags
  properties: {
    description: virtualNetworkAlertName
    enabled: false
    scopes: [
      subscription().id
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'resourceType'
          equals: 'Microsoft.Network/virtualNetworks'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: virtualNetworkActionGroupId
        }
      ]
    }
  }
}

// Resource - Alert - Virtual Machine Cpu
//////////////////////////////////////////////////
resource virtualMachineCpuAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: virtualMachineCpuAlertName
  location: 'global'
  tags: tags
  properties: {
    description: virtualMachineCpuAlertName
    enabled: false
    scopes: [
      subscription().id
    ]
    severity: 2
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    targetResourceType: 'microsoft.compute/virtualmachines'
    targetResourceRegion: azureRegion
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'Metric1'
          criterionType: 'StaticThresholdCriterion'
          metricName: 'Percentage CPU'
          metricNamespace: 'microsoft.compute/virtualmachines'
          dimensions: []
          operator: 'GreaterThan'
          threshold: 75
          timeAggregation: 'Average'
        }
      ]
    }
    actions: [
      {
        actionGroupId: virtualMachineActionGroupId
      }
    ]
  }
}
