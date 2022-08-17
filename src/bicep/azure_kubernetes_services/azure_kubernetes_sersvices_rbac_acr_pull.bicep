// Parameters
//////////////////////////////////////////////////
@description('The Id of the Acr Pull Role Definition.')
param acrPullRoleDefinitionId string

@description('The Object Id of the ADE App Aks Cluster Kubelet Identity.')
param adeAppAksClusterKubeletIdentityId string

@description('The Id of the Acr Pull Role Definition.')
param containerRegistryId string

// @description('The name of the Container Registry.')
// param containerRegistryName string

// @description('The name of the Container Registry Resource Group.')
// param containerRegistryResourceGroupName string

// Existing Resource - Container Registry
//////////////////////////////////////////////////
// resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
//   scope: resourceGroup(containerRegistryResourceGroupName)
//   name: containerRegistryName
// }

// Resource - Azure Kubernetes Service Cluster - ADE App - RBAC - Network Contributor
//////////////////////////////////////////////////
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistryId, acrPullRoleDefinitionId, adeAppAksClusterKubeletIdentityId)
  properties: {
    roleDefinitionId: acrPullRoleDefinitionId
    principalId: adeAppAksClusterKubeletIdentityId
    principalType: 'ServicePrincipal'
  }
}
