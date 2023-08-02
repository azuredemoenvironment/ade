// Parameters
//////////////////////////////////////////////////
@description('The Id of the Acr Pull Role Definition.')
param acrPullRoleDefinitionId string

@description('The Object Id of the  App Aks Cluster Kubelet Identity.')
param aksClusterKubeletIdentityId string

@description('The Id of the Acr Pull Role Definition.')
param containerRegistryId string

// Resource - Azure Kubernetes Service Cluster -  App - RBAC - Network Contributor
//////////////////////////////////////////////////
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistryId, acrPullRoleDefinitionId, aksClusterKubeletIdentityId)
  properties: {
    roleDefinitionId: acrPullRoleDefinitionId
    principalId: aksClusterKubeletIdentityId
    principalType: 'ServicePrincipal'
  }
}
