// target scope
targetScope = 'subscription'

// parameters
param defaultPrimaryRegion string
param aliasRegion string
param monitorResourceGroupName string
param networkingResourceGroupName string
param jumpboxResourceGroupName string
param nTierResourceGroupName string
param vmssResourceGroupName string
param w10clientResourceGroupName string
param adminUserName string
param adminPassword string

// existing resources
// variables
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
// resource - log analytics workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: logAnalyticsWorkspaceName
}
// variables
var virtualNetwork001Name = 'vnet-ade-${aliasRegion}-001'
var applicationGatewaySubnetName = 'snet-agw'
// resource - virtual network - virtual network 001
resource virtualNetwork001 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: virtualNetwork001Name
  resource managementSubnet 'subnets@2020-07-01' existing = {
    name: applicationGatewaySubnetName
  }
}
