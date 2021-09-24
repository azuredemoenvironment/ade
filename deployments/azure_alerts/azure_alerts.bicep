// parameters
param aliasRegion string
param azureRegion string
param contactEmailAddress string

// variables
var serviceHealthActionGroupName = 'ag-ade-${aliasRegion}-servicehealth'
var serviceHealthActionGroupShortName = 'ag-svchealth'
var virtualMachineActionGroupName = 'ag-ade-${aliasRegion}-virtualmachine'
var virtualMachineActionGroupShortName = 'ag-vm'
var virtualNetworkActionGroupName = 'ag-ade-${aliasRegion}-virtualnetwork'
var virtualNetworkActionGroupShortName = 'ag-vnet'
var serviceHealthAlertName = 'service health'
var virtualMachineAlertName = 'virtual machines - all administrative operations'
var virtualNetworkAlertName = 'virtual networks - all administrative operations'
var virtualMachineCpuAlertName = 'virtual machines - cpu utilization'
var environmentName = 'production'
var functionName = 'monitoring and diagnostics'
var costCenterName = 'it'

// resource - action group - service health
resource serviceHealthActionGroup 'microsoft.insights/actionGroups@2019-06-01' = {
  name: serviceHealthActionGroupName
  location: 'global'
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    enabled: true
    groupShortName: serviceHealthActionGroupShortName
    emailReceivers: [
      {
        name: 'email'
        emailAddress: contactEmailAddress
        useCommonAlertSchema: true
      }
    ]
  }
}

// resource - action group - virtual machine
resource virtualMachineActionGroup 'microsoft.insights/actionGroups@2019-06-01' = {
  name: virtualMachineActionGroupName
  location: 'global'
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    enabled: true
    groupShortName: virtualMachineActionGroupShortName
    emailReceivers: [
      {
        name: 'email'
        emailAddress: contactEmailAddress
        useCommonAlertSchema: true
      }
    ]
  }
}

// resource - action group - virtual network
resource virtualNetworkActionGroup 'microsoft.insights/actionGroups@2019-06-01' = {
  name: virtualNetworkActionGroupName
  location: 'global'
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    enabled: true
    groupShortName: virtualNetworkActionGroupShortName
    emailReceivers: [
      {
        name: 'email'
        emailAddress: contactEmailAddress
        useCommonAlertSchema: true
      }
    ]
  }
}

// resource - alert - service health
resource serviceHealthAlert 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: serviceHealthAlertName
  location: 'global'
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
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
          actionGroupId: serviceHealthActionGroup.id
        }
      ]
    }
  }
}

// resource - alert - virtual machine
resource virtualMachineAlert 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: virtualMachineAlertName
  location: 'global'
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
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
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: virtualMachineActionGroup.id
        }
      ]
    }
  }
}

// resource - alert - virtual network
resource virtualNetworkAlert 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: virtualNetworkAlertName
  location: 'global'
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
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
          equals: 'ServiceHealth'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: virtualNetworkActionGroup.id
        }
      ]
    }
  }
}

// resource - alert - virtual machine cpu
resource virtualMachineCpuAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: virtualMachineCpuAlertName
  location: 'global'
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
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
        actionGroupId: virtualMachineActionGroup.id
      }
    ]
  }
}
