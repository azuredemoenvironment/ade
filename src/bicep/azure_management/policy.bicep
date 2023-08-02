// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'

// Parameters
//////////////////////////////////////////////////
@description('The array of Initiative definitions.')
param initiativeDefinitions array

// Resource - Initiative Definition
//////////////////////////////////////////////////
resource initiative 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = [for (initiativeDefinition, i) in initiativeDefinitions: {
  name: initiativeDefinition.name
  properties: {
    policyType: initiativeDefinition.policyType
    displayName: initiativeDefinition.name
    description: initiativeDefinition.description
    metadata: {
      category: initiativeDefinition.category
    }
    parameters: {}
    policyDefinitions: initiativeDefinition.policyDefinitions
  }
}]

// Resource - Policy Assignment - Initiative Definition
//////////////////////////////////////////////////
resource initiativeassignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = [for (initiativeDefinition, i) in initiativeDefinitions: {
  name: initiative[i].name
  scope: subscription()
  properties: {
    enforcementMode: initiativeDefinition.enforcementMode
    policyDefinitionId: initiative[i].id
    parameters: {}
  }
}]
