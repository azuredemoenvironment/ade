// target scope
targetScope = 'subscription'

// parameters
param defaultPrimaryRegion string
param listOfAllowedLocations array
param listOfAllowedSKUs array
param logAnalyticsWorkspaceId string
param initiativeDefinitionName string

// resource - policy initiative definition
resource initiativeDefinition 'Microsoft.Authorization/policySetDefinitions@2019-09-01' = {
  name: initiativeDefinitionName
  properties: {
    policyType: 'Custom'
    displayName: initiativeDefinitionName
    description: 'Initiative Definition for Resource Location and VM SKU Size'
    metadata: {
      category: 'ADE Initiative'
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
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e765b5de-1225-4ba3-bd56-1ac6695af988'
        parameters: {
          listOfAllowedLocations: {
            value: '[parameters(\'listOfAllowedLocations\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c'
        parameters: {
          listOfAllowedLocations: {
            value: '[parameters(\'listOfAllowedLocations\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/cccc23c7-8427-4f53-ad12-b6a63eb452b3'
        parameters: {
          listOfAllowedSKUs: {
            value: '[parameters(\'listOfAllowedSKUs\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/0015ea4d-51ff-4ce3-8d8c-f3f8f0179a56'
        parameters: {}
      }
    ]
  }
}

// resource - policy assignment
resource initiativeDefinitionPolicyAssignment 'Microsoft.Authorization/policyAssignments@2019-09-01' = {
  name: initiativeDefinitionName
  properties: {
    scope: subscription().id
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

// resource - policy assignment
resource azureMonitorVMsPolicyAssignment 'Microsoft.Authorization/policyAssignments@2019-09-01' = {
  name: 'Enable Azure Monitor for VMs'
  location: defaultPrimaryRegion
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    scope: subscription().id
    enforcementMode: 'Default'
    policyDefinitionId: '/providers/Microsoft.Authorization/policySetDefinitions/55f3eceb-5573-4f18-9695-226972c6d74a'
    parameters: {
      logAnalytics_1: {
        value: logAnalyticsWorkspaceId
      }
    }
  }
}

// resource - policy assignment
resource azureMonitorVMSSPolicyAssignment 'Microsoft.Authorization/policyAssignments@2019-09-01' = {
  name: 'Enable Azure Monitor for Virtual Machine Scale Sets'
  location: defaultPrimaryRegion
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    scope: subscription().id
    enforcementMode: 'Default'
    policyDefinitionId: '/providers/Microsoft.Authorization/policySetDefinitions/75714362-cae7-409e-9b99-a8e5075b7fad'
    parameters: {
      logAnalytics_1: {
        value: logAnalyticsWorkspaceId
      }
    }
  }
}
