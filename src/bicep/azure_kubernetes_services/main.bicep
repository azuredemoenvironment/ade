// Parameters
//////////////////////////////////////////////////
@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('The name of the Container Resource Group.')
param containerResourceGroupName string

@description('The date of the resource deployment.')
param deploymentDate string = utcNow('yyyy-MM-dd')

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of the Management Resource Group.')
param managementResourceGroupName string

@description('The name of the Networking Resource Group.')
param networkingResourceGroupName string

@description('The name of the owner of the deployment.')
param ownerName string

// Variables
//////////////////////////////////////////////////
var acrPullRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var aksClusterDNSName = 'aks-${appEnvironment}-001-dns'
var aksClusterName = 'aks-${appEnvironment}-001'
var aksDNSServiceIPAddress = '192.168.0.10'
var aksDockerBridgeAddress = '172.17.0.1/16'
var aksNodeResourceGroupName = '${containerResourceGroupName}-node'
var aksServiceAddressPrefix = '192.168.0.0/24'
var networkContributorRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7')
var tags = {
  deploymentDate: deploymentDate
  owner: ownerName
}

// Existing Resource - Container Registry
//////////////////////////////////////////////////
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' existing = {
  scope: resourceGroup(containerResourceGroupName)
  name: replace('acr-${appEnvironment}-001', '-', '')
}

// Existing Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: 'log-${appEnvironment}-001'
}

// Existing Resource - Virtual Network - Virtual Network 002
//////////////////////////////////////////////////
resource virtualNetwork002 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'vnet-${appEnvironment}-002'
  resource aksSubnet 'subnets@2020-07-01' existing = {
    name: 'snet-${appEnvironment}-adeapp-aks'
  }
}

// Module - Azure Kubernetes Services Cluster
//////////////////////////////////////////////////
module aksModule 'aks.bicep' = {
  name: 'aksClusterDeployment'
  params: {
    aksClusterDNSName: aksClusterDNSName
    aksClusterName: aksClusterName
    aksDNSServiceIPAddress: aksDNSServiceIPAddress
    aksDockerBridgeAddress: aksDockerBridgeAddress
    aksNodeResourceGroupName: aksNodeResourceGroupName
    aksServiceAddressPrefix: aksServiceAddressPrefix
    aksSubnetId: virtualNetwork002::aksSubnet.id
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    tags: tags
  }
}

// Module - Azure Kubernetes Services Cluster - RBAC - Network Contributor
//////////////////////////////////////////////////
module aksRbacNetworkContributor 'aks_rbac_network_contributor.bicep' = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'aksClusterRbacNetworkContributorDeployment'
  params: {
    aksClusterPrincipalId: aksModule.outputs.aksClusterPrincipalId
    aksSubnetId: virtualNetwork002::aksSubnet.id
    networkContributorRoleDefinitionId: networkContributorRoleDefinitionId
  }
}

// Module - Azure Kubernetes Services Cluster - RBAC - Acr Pull
//////////////////////////////////////////////////
module aksRbacAcrPull 'aks_rbac_acr_pull.bicep' = {
  scope: resourceGroup(containerResourceGroupName)
  name: 'aksClusterRbacAcrPullDeployment'
  params: {
    acrPullRoleDefinitionId: acrPullRoleDefinitionId
    aksClusterKubeletIdentityId: aksModule.outputs.aksClusterKubeletIdentityId
    containerRegistryId: containerRegistry.id
  }
}
