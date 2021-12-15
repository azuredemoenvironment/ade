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
var adeBudgetAmount = 1500
var adeBudgetFirstThreshold = 10
var adeBudgetName = 'budget-ade-${aliasRegion}-monthly'
var adeBudgetSecondThreshold = 50
var adeBudgetThirdThreshold = 100
var adeBudgetTimeGrain = 'Monthly'
var budgetActionGroupName = 'ag-ade-${aliasRegion}-budget'
var budgetActionGroupShortName = 'ag-budget'
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
    budgetActionGroupName: budgetActionGroupName
    budgetActionGroupShortName: budgetActionGroupShortName
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

// Module - Budget
//////////////////////////////////////////////////
module budgetModule 'azure_alerts_budget.bicep' = {
  name: 'budgetDeployment'
  params: {
    adeBudgetAmount: adeBudgetAmount
    adeBudgetFirstThreshold: adeBudgetFirstThreshold
    adeBudgetName: adeBudgetName
    adeBudgetSecondThreshold: adeBudgetSecondThreshold
    adeBudgetThirdThreshold: adeBudgetThirdThreshold
    adeBudgetTimeGrain: adeBudgetTimeGrain
    budgetActionGroupId: actionGroupModule.outputs.budgetActionGroupId
    contactEmailAddress: contactEmailAddress
  }
}
