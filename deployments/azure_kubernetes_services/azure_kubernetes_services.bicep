// Target Scope
targetScope = 'subscription'

// Parameters
@description('Parameter for the default primary Azure region. Currently set to East US. Defined in azure_kubernetes_services.parameters.json.')
param defaultPrimaryRegion string

@description('Parameter for the user alias and default primary Azure region defined from user input. Defined in azure_kubernetes_services.parameters.json.')
param aliasRegion string

// Variables
var aksResourceGroupName = 'rg-ade-${aliasRegion}-monitor-aks'

// Existing Resources
// Variables
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
// Resource - Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: logAnalyticsWorkspaceName
}

// Existing Resource
// Variables
var networkingResourceGroupName = 'rg-ade-${aliasRegion}-networking'
var virtualNetwork002Name = 'vnet-ade-${aliasRegion}-002'
var aksSubnetName = 'snet-ade-${aliasRegion}-aks'
// Resource - Virtual Network - Virtual Network 002
resource virtualNetwork002 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: virtualNetwork002Name
  resource aksSubnet 'subnets@2020-07-01' existing = {
    name: aksSubnetName
  }
}

// Module - Azure Kubernetes Services RBAC Assignment
// Variables
// Module Deployment

// Module - Azure Kubernetes Services Cluster
// Variables
var aksNodeResourceGroupName = 'rg-ade-${aliasRegion}-aks-node'
var aksClusterName = 'aks-ade-${aliasRegion}-001'
var aksClusterDNSName = 'aks-ade-${aliasRegion}-001-dns'
var aksServiceAddressPrefix = '192.168.0.0/24'
var aksDNSServiceIPAddress = '192.168.0.10'
var aksDockerBridgeAddress = '172.17.0.1/16'
// Module Deployment
module aksClusterModule 'azure_kubernetes_services_cluster.bicep' = {
  scope: resourceGroup(aksResourceGroupName)
  name: 'aksClusterDeployment'
  params: {
    location: defaultPrimaryRegion
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    aksSubnetId: virtualNetwork002::aksSubnet.id
    aksClusterName: aksClusterName
    aksNodeResourceGroupName: aksNodeResourceGroupName
    aksClusterDNSName: aksClusterDNSName
    aksServiceAddressPrefix: aksServiceAddressPrefix
    aksDNSServiceIPAddress: aksDNSServiceIPAddress
    aksDockerBridgeAddress: aksDockerBridgeAddress
  }
}
