// Parameters
//////////////////////////////////////////////////
@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('The name of the Container Resource Group.')
param containerResourceGroupName string

@description('The current date.')
param currentDate string = utcNow('yyyy-MM-dd')

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
var tags = {
  deploymentDate: currentDate
  owner: ownerName
}

// Variables - Azure Kubernetes Services
//////////////////////////////////////////////////
var aksClusterDnsName = 'aks-${appEnvironment}-dns'
var aksClusterName = 'aks-${appEnvironment}'
var aksProperties = {
  name: aksClusterName
  identityType: 'SystemAssigned'
  kubernetesVersion: '1.24.10'
  nodeResourceGroup: '${containerResourceGroupName}-node'
  enableRBAC: true
  dnsPrefix: aksClusterDnsName
  agentPoolProfiles: aksAgentPoolProfiles
  loadBalancerSku: 'standard'
  networkPlugin: 'azure'
  serviceCidr: '192.168.0.0/24'
  dnsServiceIP: '192.168.0.10'
  dockerBridgeCidr: '172.17.0.1/16'
  httpApplicationRoutingEnabled: true
  omsAgentEnabled: true
}

// Variables - Azure Kubernetes Services - Agent Profiles
//////////////////////////////////////////////////
var aksAgentPoolProfiles = [
  {
    name: 'agentpool'
    osDiskSizeGB: 0
    count: 3
    enableAutoScaling: true
    minCount: 1
    maxCount: 3
    vmSize: 'Standard_B2s'
    osType: 'Linux'
    type: 'VirtualMachineScaleSets'
    mode: 'System'
    maxPods: 110
    availabilityZones: ['1', '2', '3']
    vnetSubnetID: spokeVirtualNetwork::adeAppAksSubnet.id
    tags: tags
  }
]

// Variables - Role Assignment - Network Contributor
//////////////////////////////////////////////////
var networkContributorRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7')

// Variables - Role Assignment - Acr Pull
/////////////////////////////////////////////////
var acrPullRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

// Variables - Existing Resources
//////////////////////////////////////////////////
var containerRegistryName = replace('acr-${appEnvironment}', '-', '')
var logAnalyticsWorkspaceName = 'log-${appEnvironment}'
var spokeVirtualNetworkName = 'vnet-${appEnvironment}-spoke'
var adeAppAksSubnetName = 'snet-${appEnvironment}-aks'

// Existing Resource - Container Registry
//////////////////////////////////////////////////
// Existing Resource - Container Registry
//////////////////////////////////////////////////
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' existing = {
  scope: resourceGroup(containerResourceGroupName)
  name: containerRegistryName
}

// Existing Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: logAnalyticsWorkspaceName
}

// Existing Resource - Virtual Network - Spoke
//////////////////////////////////////////////////
resource spokeVirtualNetwork 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: spokeVirtualNetworkName
  resource adeAppAksSubnet 'subnets@2022-09-01' existing = {
    name: adeAppAksSubnetName
  }
}

// Module - Azure Kubernetes Services
//////////////////////////////////////////////////
module aksModule 'aks.bicep' = {
  name: 'aksClusterDeployment'
  params: {
    aksProperties: aksProperties
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    tags: tags
  }
}

// Module - Azure Kubernetes Services - RBAC - Network Contributor
//////////////////////////////////////////////////
module aksRbacNetworkContributor 'aks_rbac_network_contributor.bicep' = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'aksClusterRbacNetworkContributorDeployment'
  params: {
    aksClusterPrincipalId: aksModule.outputs.aksClusterPrincipalId
    aksSubnetId: spokeVirtualNetwork::adeAppAksSubnet.id
    networkContributorRoleDefinitionId: networkContributorRoleDefinitionId
  }
}

// Module - Azure Kubernetes Services Cluster - RBAC - Acr Pull
//////////////////////////////////////////////////
module aksRbacAcrPull 'aks_rbac_acr_pull.bicep' = {
  name: 'aksClusterRbacAcrPullDeployment'
  params: {
    acrPullRoleDefinitionId: acrPullRoleDefinitionId
    aksClusterKubeletIdentityId: aksModule.outputs.aksClusterKubeletIdentityId
    containerRegistryId: containerRegistry.id
  }
}
