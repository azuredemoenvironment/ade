// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'

// Parameters
//////////////////////////////////////////////////
@description('The user alias and Azure region defined from user input.')
param aliasRegion string

@description('The selected Azure region for deployment.')
param azureRegion string

// Global Variables
//////////////////////////////////////////////////
// Resource Groups
var adeAppAksNodeResourceGroupName = 'rg-ade-${aliasRegion}-adeappaks-node'
var adeAppAksResourceGroupName = 'rg-ade-${aliasRegion}-adeappaks'
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
var networkingResourceGroupName = 'rg-ade-${aliasRegion}-networking'
// Resources
var adeAppAksClusterDNSName = 'aks-ade-${aliasRegion}-001-dns'
var adeAppAksClusterName = 'aks-ade-${aliasRegion}-001'
var adeAppAksDNSServiceIPAddress = '192.168.0.10'
var adeAppAksDockerBridgeAddress = '172.17.0.1/16'
var adeAppAksServiceAddressPrefix = '192.168.0.0/24'
var adeAppAksSubnetName = 'snet-ade-${aliasRegion}-adeapp-aks'
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
var virtualNetwork002Name = 'vnet-ade-${aliasRegion}-002'

// Existing Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: logAnalyticsWorkspaceName
}

// Existing Resource - Virtual Network - Virtual Network 002
//////////////////////////////////////////////////
resource virtualNetwork002 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: virtualNetwork002Name
  resource adeAppAksSubnet 'subnets@2020-07-01' existing = {
    name: adeAppAksSubnetName
  }
}

// Resource Group - Azure Kubernetes Services
//////////////////////////////////////////////////
resource adeAppAksResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: adeAppAksResourceGroupName
  location: azureRegion
}

// Module - Azure Kubernetes Services RBAC Assignment
//////////////////////////////////////////////////

// Module - Azure Kubernetes Services Cluster
//////////////////////////////////////////////////
module aksClusterModule 'azure_kubernetes_services_cluster.bicep' = {
  scope: resourceGroup(adeAppAksResourceGroupName)
  name: 'aksClusterDeployment'
  dependsOn: [
    adeAppAksResourceGroup
  ]
  params: {
    adeAppAksClusterDNSName: adeAppAksClusterDNSName
    adeAppAksClusterName: adeAppAksClusterName
    adeAppAksDNSServiceIPAddress: adeAppAksDNSServiceIPAddress
    adeAppAksDockerBridgeAddress: adeAppAksDockerBridgeAddress
    adeAppAksNodeResourceGroupName: adeAppAksNodeResourceGroupName
    adeAppAksServiceAddressPrefix: adeAppAksServiceAddressPrefix
    adeAppAksSubnetId: virtualNetwork002::adeAppAksSubnet.id
    adeAppAksSubnetName: adeAppAksSubnetName
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    networkingResourceGroupName: networkingResourceGroupName
    virtualNetwork002Name: virtualNetwork002Name
  }
}
