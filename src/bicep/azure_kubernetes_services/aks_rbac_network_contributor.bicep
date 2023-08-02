// Parameters
//////////////////////////////////////////////////
@description('The Principal Id of the  App Aks Cluster.')
param aksClusterPrincipalId string

@description('The Id of the  App Aks Subnet.')
param aksSubnetId string

@description('The Id of the Network Contributor Role Definition.')
param networkContributorRoleDefinitionId string

// Resource - Azure Kubernetes Service Cluster -  App - RBAC - Network Contributor
//////////////////////////////////////////////////
resource networkContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(aksSubnetId, aksClusterPrincipalId, networkContributorRoleDefinitionId)
  properties: {
    roleDefinitionId: networkContributorRoleDefinitionId
    principalId: aksClusterPrincipalId
    principalType: 'ServicePrincipal'
  }
}
