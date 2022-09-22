// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'

// Parameters
//////////////////////////////////////////////////
@description('The user alias and Azure region defined from user input.')
param aliasRegion string

@description('The selected Azure region for deployment.')
param azureRegion string

@description('The location for all resources.')
param location string = deployment().location

// Global Variables
//////////////////////////////////////////////////
// Resource Groups
// var containerRegistryResourceGroupName = 'rg-ade-${aliasRegion}-containerregistry'
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
var containerAppsResourceGroupName = 'rg-ade-${aliasRegion}-containerapps'

// Resources
var containerAppsName = replace('capps-ade-${aliasRegion}-001', '-', '')
var containerAppsEnvironmantName = replace('caenv-ade-${aliasRegion}-001', '-', '')
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'

// Existing Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: logAnalyticsWorkspaceName
}

// // Resource Group - Container Registry
// //////////////////////////////////////////////////
// resource containerRegistryResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
//   name: containerRegistryResourceGroupName
//   location: azureRegion
// }

// Module - Container Apps Environment - ADE App
//////////////////////////////////////////////////
module containerAppsEnvironmentModule './azure_container_apps_adeapps_env.bicep' = {
  scope: resourceGroup(containerAppsResourceGroupName)
  name: 'containerAppsEnvironmentDeployment'
  params: {
    location: location
    logAnalyticsWorkspaceCustomerId: logAnalyticsWorkspace.properties.customerId
    logAnalyticsWorkspacePrimarySharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
    contanierAppsEnvironmentName: containerAppsEnvironmantName
  }
}

// Module - Container Apps - ADE App
//////////////////////////////////////////////////
module containerAppsModule './azure_container_apps_adeapps.bicep' = {
  scope: resourceGroup(containerAppsResourceGroupName)
  name: 'containerAppsDeployment'
  dependsOn: [
    containerAppsEnvironmentModule
  ]
  params: {
    location: location
    containerAppsName: containerAppsName
    contanierAppsEnvironmentId: containerAppsEnvironmentModule.outputs.id
  }
}
