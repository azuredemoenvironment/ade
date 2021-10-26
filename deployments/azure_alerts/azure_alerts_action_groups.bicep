// Parameters
//////////////////////////////////////////////////
@description('The Email Address used for Alerts and Notifications.')
param contactEmailAddress string

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
var location = 'global'
var tags = {
  environment: 'production'
  function: 'monitoring and diagnostics'
  costCenter: 'it'
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
output serviceHealthActionGroupId string = serviceHealthActionGroup.id
output virtualMachineActionGroupId string = serviceHealthActionGroup.id
output virtualNetworkActionGroupId string = serviceHealthActionGroup.id
