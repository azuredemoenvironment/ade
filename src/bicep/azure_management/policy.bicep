// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'

// Parameters
//////////////////////////////////////////////////
@description('The ID of the "Allowed locations" Policy definition.')
param allowedLocations string

@description('The ID of the "Allowed locations for resource groups" Policy definition.')
param allowedLocationsForResourceGroups string

@description('The ID of the "Allowed virtual machine size SKUs" Policy definition.')
param allowedVirtualMachineSizeSkus string

@description('The ID of the "	Audit virtual machines without disaster recovery configured" Policy definition.')
param auditVirtualMachinesWithoutDisasterRecoveryConfigured string

@description('The name of the Azure Policy Initiative definition.')
param initiativeDefinitionName string

@description('The list of allowed locations for resource deployment.')
param listOfAllowedLocations array

@description('The list of allowed virtual machine skus.')
param listOfAllowedSKUs array


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
    parameters: {
      listOfAllowedLocations: {
        type: 'Array'
        metadata: {
          description: 'The List of Allowed Locations for Resource Groups and Resources.'
          strongtype: 'location'
          displayName: 'Allowed Locations'
        }
      }
      listOfAllowedSKUs: {
        type: 'Array'
        metadata: {
          description: 'The List of Allowed SKUs for Virtual Machines.'
          strongtype: 'vmSKUs'
          displayName: 'Allowed Virtual Machine Size SKUs'
        }
      }
    }
    policyDefinitions: [
      {
        policyDefinitionId: allowedLocationsForResourceGroups
        parameters: {
          listOfAllowedLocations: {
            value: '[parameters(\'listOfAllowedLocations\')]'
          }
        }
      }
      {
        policyDefinitionId: allowedLocations
        parameters: {
          listOfAllowedLocations: {
            value: '[parameters(\'listOfAllowedLocations\')]'
          }
        }
      }
      {
        policyDefinitionId: allowedVirtualMachineSizeSkus
        parameters: {
          listOfAllowedSKUs: {
            value: '[parameters(\'listOfAllowedSKUs\')]'
          }
        }
      }
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
    enforcementMode: 'Default'
    policyDefinitionId: initiativeDefinition.id
    parameters: {
      listOfAllowedLocations: {
        value: listOfAllowedLocations
      }
      listOfAllowedSKUs: {
        value: listOfAllowedSKUs
      }
    }
  }
}
