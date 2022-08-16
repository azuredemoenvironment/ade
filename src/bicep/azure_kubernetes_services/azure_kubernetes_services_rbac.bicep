// Parameters
//////////////////////////////////////////////////
@description('The Id of the Acr Pull Role Definition.')
param acrPullRoleDefinitionId string

@description('The Principal Id of the ADE App AKS Cluster.')
param adeAppAksClusterPrincipalId string

@description('The ID of the ADE App AKS Subnet.')
param adeAppAksSubnetId string

@description('The ID of the Container Registry.')
param containerRegistryId string

@description('The Id of the Network Contributor Role Definition.')
param networkContributorRoleDefinitionId string

// Resource - Azure Kubernetes Service Cluster - ADE App - RBAC - Network Contributor
//////////////////////////////////////////////////
resource networkContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(adeAppAksSubnetId, networkContributorRoleDefinitionId, adeAppAksClusterPrincipalId)
  properties: {
    roleDefinitionId: networkContributorRoleDefinitionId
    principalId: adeAppAksClusterPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Resource - Azure Kubernetes Service Cluster - ADE App - RBAC - Network Contributor
//////////////////////////////////////////////////
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistryId, acrPullRoleDefinitionId, adeAppAksClusterPrincipalId)
  properties: {
    roleDefinitionId: acrPullRoleDefinitionId
    principalId: adeAppAksClusterPrincipalId
    principalType: 'ServicePrincipal'
  }
}
