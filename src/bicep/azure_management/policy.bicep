// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'

// Parameters
//////////////////////////////////////////////////
@description('The ID of the "	Audit virtual machines without disaster recovery configured" Policy definition.')
param auditVirtualMachinesWithoutDisasterRecoveryConfigured string

@description('The enforcement mode of the Azure Policy Initiative definition.')
param initiativeDefinitionEnforcementMode string

@description('The name of the Azure Policy Initiative definition.')
param initiativeDefinitionName string

// Resource - Initiative Definition
//////////////////////////////////////////////////
resource initiativeDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: initiativeDefinitionName
  properties: {
    policyType: 'Custom'
    displayName: initiativeDefinitionName
    description: 'Initiative Definition for Resource Location and VM SKU Size'
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
  name: initiativeDefinitionName
  scope: subscription()
  properties: {
    enforcementMode: initiativeDefinitionEnforcementMode
    policyDefinitionId: initiativeDefinition.id
    parameters: {}
  }
}
