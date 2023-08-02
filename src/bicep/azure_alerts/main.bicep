// Parameters
//////////////////////////////////////////////////
@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('The Email Address used for Alerts and Notifications.')
param contactEmailAddress string

@description('The current date.')
param currentDate string = utcNow('yyyy-MM-dd')

@description('Function to generate the current time.')
param currentTime string = utcNow('yyyy-MM-01')

@description('The location for all resources.')
param location string

@description('The name of the owner of the deployment.')
param ownerName string

// Variables
//////////////////////////////////////////////////
var tags = {
  deploymentDate: currentDate
  owner: ownerName
}

// Variables - Action Groups
//////////////////////////////////////////////////
var actionGroups = [
  {
    name: 'ag-${appEnvironment}-budget'
    enabled: true 
    groupShortName: 'ag-budget'
    emailReceiversName: 'email'
    emailAddress: contactEmailAddress
    useCommonAlertSchema: true
  }
  {
    name: 'ag-${appEnvironment}-servicehealth'
    enabled: true 
    groupShortName: 'ag-svchealth'
    emailReceiversName: 'email'
    emailAddress: contactEmailAddress
    useCommonAlertSchema: true
  }
  {
    name: 'ag-${appEnvironment}-virtualmachine'
    enabled: true 
    groupShortName: 'ag-vm'
    emailReceiversName: 'email'
    emailAddress: contactEmailAddress
    useCommonAlertSchema: true
  }
  {
    name: 'ag-${appEnvironment}-virtualnetwork'
    enabled: true 
    groupShortName: 'ag-vnet'
    emailReceiversName: 'email'
    emailAddress: contactEmailAddress
    useCommonAlertSchema: true
  }
]

// Variables - Alerts
//////////////////////////////////////////////////
var serviceHealthAlertName = 'service health'
var virtualMachineAlertName = 'virtual machines - all administrative operations'
var virtualMachineCpuAlertName = 'virtual machines - cpu utilization'
var virtualNetworkAlertName = 'virtual networks - all administrative operations'

// Variables - Budget
//////////////////////////////////////////////////
var budgetProperties = {
  name: 'budget-${appEnvironment}-monthly'
  startDate: currentTime
  timeGrain: 'Monthly'
  amount: 1500
  category: 'Cost'
  operator: 'GreaterThan'
  enabled: true 
  firstThreshold: 10
  secondThreshold: 50
  thirdThreshold: 100
  forcastedThreshold: 150
  contactEmails: contactEmailAddress
  contactGroups: actionGroupsModule.outputs.actionGroupIds[0].actionGroupId
}

// Module - Action Groups
//////////////////////////////////////////////////
module actionGroupsModule 'action_groups.bicep' = {
  name: 'actionGroupsDeployment'
  params: {
    actionGroups: actionGroups
    location: location
    tags: tags
  }
}

// Module - Alerts
//////////////////////////////////////////////////
module alertsModule 'alerts.bicep' = {
  name: 'alertsDeployment'
  params: {
    azureRegion: azureRegion
    serviceHealthActionGroupId: actionGroupModule.outputs.serviceHealthActionGroupId
    serviceHealthAlertName: serviceHealthAlertName
    virtualMachineActionGroupId: actionGroupModule.outputs.virtualMachineActionGroupId
    virtualMachineAlertName: virtualMachineAlertName
    virtualMachineCpuAlertName: virtualMachineCpuAlertName
    virtualNetworkActionGroupId: actionGroupModule.outputs.virtualNetworkActionGroupId
    virtualNetworkAlertName: virtualNetworkAlertName
  }
}

// Module - Budget
//////////////////////////////////////////////////
module budgetModule 'budget.bicep' = {
  scope: subscription()
  name: 'budgetDeployment'
  params: {
    budgetProperties: budgetProperties
  }
}
