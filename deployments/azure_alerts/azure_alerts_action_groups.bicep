// Parameters
//////////////////////////////////////////////////
@description('The Email Address used for Alerts and Notifications.')
param contactEmailAddress string

@description('The name of the Budget Action Group.')
param budgetActionGroupName string

@description('The short name of the Budget Action Group.')
param budgetActionGroupShortName string

@description('The region location of deployment.')
param location string = 'global'

@description('The name of the Service Health Action Group.')
param serviceHealthActionGroupName string

@description('The short name of the Service Health Action Group.')
param serviceHealthActionGroupShortName string

@description('The name of the Virtual Machine Action Group.')
param virtualMachineActionGroupName string

@description('The short name of the Virtual Machine Action Group.')
param virtualMachineActionGroupShortName string

@description('The name of the Virtual Network Action Group.')
param virtualNetworkActionGroupName string

@description('The short name of the Virtual Network Action Group.')
param virtualNetworkActionGroupShortName string

// Variables
//////////////////////////////////////////////////
var tags = {
  environment: 'production'
  function: 'monitoring and diagnostics'
  costCenter: 'it'
}

// Resource - Action Group - Budget
//////////////////////////////////////////////////
resource budgetActionGroup 'microsoft.insights/actionGroups@2019-06-01' = {
  name: budgetActionGroupName
  location: location
  tags: tags
  properties: {
    enabled: true
    groupShortName: budgetActionGroupShortName
    emailReceivers: [
      {
        name: 'email'
        emailAddress: contactEmailAddress
        useCommonAlertSchema: true
      }
    ]
  }
}

// Resource - Action Group - Service Health
//////////////////////////////////////////////////
resource serviceHealthActionGroup 'microsoft.insights/actionGroups@2019-06-01' = {
  name: serviceHealthActionGroupName
  location: location
  tags: tags
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

// Resource - Action Group - Virtual Machine
//////////////////////////////////////////////////
resource virtualMachineActionGroup 'microsoft.insights/actionGroups@2019-06-01' = {
  name: virtualMachineActionGroupName
  location: location
  tags: tags
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

// Resource - Action Group - Virtual Network
//////////////////////////////////////////////////
resource virtualNetworkActionGroup 'microsoft.insights/actionGroups@2019-06-01' = {
  name: virtualNetworkActionGroupName
  location: location
  tags: tags
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

// Outputs - Action Group
//////////////////////////////////////////////////
output budgetActionGroupId string = budgetActionGroup.id
output serviceHealthActionGroupId string = serviceHealthActionGroup.id
output virtualMachineActionGroupId string = virtualMachineActionGroup.id
output virtualNetworkActionGroupId string = virtualNetworkActionGroup.id
