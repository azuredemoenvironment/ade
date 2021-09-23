// Resource - Role Assignment
// resource - role asignment - acr pull
resource azureContainerRegistryRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: azureContainerRegistry
  name: guid(resourceGroup().id, roleDefinitionId, containerRegistrySPNObjectID)
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: containerRegistrySPNObjectID
    principalType: 'ServicePrincipal'
  }
}
