// Parameters
//////////////////////////////////////////////////
@description('The Principal ID of the Automation Account.')
param automationAccountPrincipalId string

@description('The Id of the Contributor role definition.')
param contributorRoleDefinitionId string

// Resource - Role Assignment - Contributor
//////////////////////////////////////////////////
resource roleAssignmentApp 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().subscriptionId, contributorRoleDefinitionId, automationAccountPrincipalId)
  properties: {
    roleDefinitionId: contributorRoleDefinitionId
    principalId: automationAccountPrincipalId
    principalType: 'ServicePrincipal'
  }
}
