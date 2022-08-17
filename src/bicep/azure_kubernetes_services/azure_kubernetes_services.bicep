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
var containerRegistryResourceGroupName = 'rg-ade-${aliasRegion}-containerregistry'
var networkingResourceGroupName = 'rg-ade-${aliasRegion}-networking'
// Resources
var acrPullRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var adeAppAksClusterDNSName = 'aks-ade-${aliasRegion}-001-dns'
var adeAppAksClusterName = 'aks-ade-${aliasRegion}-001'
var adeAppAksDNSServiceIPAddress = '192.168.0.10'
var adeAppAksDockerBridgeAddress = '172.17.0.1/16'
var adeAppAksNodeResourceGroupName = 'rg-ade-${aliasRegion}-adeappaks-node'
var adeAppAksResourceGroupName = 'rg-ade-${aliasRegion}-adeappaks'
var adeAppAksServiceAddressPrefix = '192.168.0.0/24'
var adeAppAksSubnetName = 'snet-ade-${aliasRegion}-adeapp-aks'
var containerRegistryName = replace('acr-ade-${aliasRegion}-001', '-', '')
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
var networkContributorRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7')
var virtualNetwork002Name = 'vnet-ade-${aliasRegion}-002'

// Existing Resource - Container Registry
//////////////////////////////////////////////////
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' existing = {
  scope: resourceGroup(containerRegistryResourceGroupName)
  name: containerRegistryName
}

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

// Module - Azure Kubernetes Services Cluster
//////////////////////////////////////////////////
module adeAppAksClusterModule 'azure_kubernetes_services_cluster.bicep' = {
  scope: resourceGroup(adeAppAksResourceGroupName)
  name: 'adeAppAksClusterDeployment'
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
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
  }
}

// Module - Azure Kubernetes Services Cluster - RBAC - Network Contributor
//////////////////////////////////////////////////
module adeAppAksClusterRbacNetworkContributor 'azure_kubernetes_services_rbac_network_contributor.bicep' = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'adeAppAksClusterRbacNetworkContributorDeployment'
  params: {
    adeAppAksClusterPrincipalId: adeAppAksClusterModule.outputs.adeAppAksClusterPrincipalId
    adeAppAksSubnetId: virtualNetwork002::adeAppAksSubnet.id
    networkContributorRoleDefinitionId: networkContributorRoleDefinitionId
  }
}

// Module - Azure Kubernetes Services Cluster - RBAC - Acr Pull
//////////////////////////////////////////////////
module adeAppAksClusterRbacAcrPull 'azure_kubernetes_services_rbac_acr_pull.bicep' = {
  scope: resourceGroup(containerRegistryResourceGroupName)
  name: 'adeAppAksClusterRbacAcrPullDeployment'
  params: {
    acrPullRoleDefinitionId: acrPullRoleDefinitionId
    adeAppAksClusterKubeletIdentityId: adeAppAksClusterModule.outputs.adeAppAksClusterKubeletIdentityId
    containerRegistryId: containerRegistry.id
  }
}
