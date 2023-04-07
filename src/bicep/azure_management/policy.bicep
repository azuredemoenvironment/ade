// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'

// Parameters
//////////////////////////////////////////////////
@description('The ID of the "	Audit virtual machines without disaster recovery configured" Policy definition.')
param auditVirtualMachinesWithoutDisasterRecoveryConfigured string

@description('The properties of the Initiative definition.')
param initiativeDefinitionProperties object

// Resource - Initiative Definition
//////////////////////////////////////////////////
resource initiativeDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: initiativeDefinitionProperties.name
  properties: {
    policyType: 'Custom'
    displayName: initiativeDefinitionProperties.name
    description: initiativeDefinitionProperties.description
    metadata: {
      category: ' Initiative'
    }
    parameters: {}
    policyDefinitions: [
      {
        policyDefinitionId: auditVirtualMachinesWithoutDisasterRecoveryConfigured
        parameters: {}
      }
    ]
  }
}

// Resource - Policy Assignment - Initiative Definition
//////////////////////////////////////////////////
resource initiativeDefinitionPolicyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: initiativeDefinitionProperties.name
  scope: subscription()
  properties: {
    enforcementMode: initiativeDefinitionProperties.enforcementMode
    policyDefinitionId: initiativeDefinition.id
    parameters: {}
  }
}
