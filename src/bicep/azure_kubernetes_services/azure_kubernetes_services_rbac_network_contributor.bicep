// Parameters
//////////////////////////////////////////////////
@description('The Principal Id of the ADE App Aks Cluster.')
param adeAppAksClusterPrincipalId string

@description('The Id of the ADE App Aks Subnet.')
param adeAppAksSubnetId string

@description('The Id of the Network Contributor Role Definition.')
param networkContributorRoleDefinitionId string

// Resource - Azure Kubernetes Service Cluster - ADE App - RBAC - Network Contributor
//////////////////////////////////////////////////
resource networkContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(adeAppAksSubnetId, adeAppAksClusterPrincipalId, networkContributorRoleDefinitionId)
  properties: {
    roleDefinitionId: networkContributorRoleDefinitionId
    principalId: adeAppAksClusterPrincipalId
    principalType: 'ServicePrincipal'
  }
}
