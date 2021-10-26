// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'

// Parameters
//////////////////////////////////////////////////
@description('The user alias and Azure region defined from user input.')
param aliasRegion string

@description('The selected Azure region for deployment.')
param azureRegion string

@description('The Email Address used for Alerts and Notifications.')
param contactEmailAddress string

// Global Variables
//////////////////////////////////////////////////
// Resource Groups
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
// Resources
var serviceHealthActionGroupName = 'ag-ade-${aliasRegion}-servicehealth'
var serviceHealthActionGroupShortName = 'ag-svchealth'
var serviceHealthAlertName = 'service health'
var virtualMachineActionGroupName = 'ag-ade-${aliasRegion}-virtualmachine'
var virtualMachineActionGroupShortName = 'ag-vm'
var virtualMachineAlertName = 'virtual machines - all administrative operations'
var virtualMachineCpuAlertName = 'virtual machines - cpu utilization'
var virtualNetworkActionGroupName = 'ag-ade-${aliasRegion}-virtualnetwork'
var virtualNetworkActionGroupShortName = 'ag-vnet'
var virtualNetworkAlertName = 'virtual networks - all administrative operations'

// Module - Action Groups
//////////////////////////////////////////////////
module actionGroupModule 'azure_alerts_action_groups.bicep' = {
  scope: resourceGroup(monitorResourceGroupName)
  name: 'actionGroupDeployment'
  params: {
    contactEmailAddress: contactEmailAddress
    serviceHealthActionGroupName: serviceHealthActionGroupName
    serviceHealthActionGroupShortName: serviceHealthActionGroupShortName
    virtualMachineActionGroupName: virtualMachineActionGroupName
    virtualMachineActionGroupShortName: virtualMachineActionGroupShortName
    virtualNetworkActionGroupName: virtualNetworkActionGroupName
    virtualNetworkActionGroupShortName: virtualNetworkActionGroupShortName
  }
}

// Module - Alerts
//////////////////////////////////////////////////
module alertsModule 'azure_alerts_alerts.bicep' = {
  scope: resourceGroup(monitorResourceGroupName)
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
