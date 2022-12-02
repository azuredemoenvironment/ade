// Parameters
//////////////////////////////////////////////////
@description('The name of the Application Gateway Managed Identity.')
param applicationGatewayManagedIdentityName string

@description('The name of the Container Registry Managed Identity.')
param containerRegistryManagedIdentityName string

// @description('The name of the Automation Account Managed Identity.')
// param automationAccountManagedIdentityName string

@description('The location for all resources.')
param location string

// Variables
//////////////////////////////////////////////////
var tags = {
  environment: 'production'
  function: 'identity'
  costCenter: 'it'
}

//var virtualMachineContributorId =resourceId('Microsoft.Authorization/roleDefinitions','9980e02c-c2be-4d73-94e8-173b1dc7cf3c')

// Resource - Managed Identity - Application Gateway
//////////////////////////////////////////////////
resource applicationGatewayManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: applicationGatewayManagedIdentityName
  location: location
  tags: tags
}

// Resource - Managed Identity - Container Registry
//////////////////////////////////////////////////
resource containerRegistryManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: containerRegistryManagedIdentityName
  location: location
  tags: tags
}


// Resource - Managed Identity - Automation Account
//////////////////////////////////////////////////
// resource automationAccountManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
//   name: automationAccountManagedIdentityName
//   location: location
//   tags: tags
// }

// resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(subscription().subscriptionId,virtualMachineContributorId)
//   properties: {
//     roleDefinitionId: virtualMachineContributorId
//     principalId: automationAccountManagedIdentity.properties.principalId
//     principalType: 'ServicePrincipal'
//   }
// }
// Outputs
//////////////////////////////////////////////////
output applicationGatewayManagedIdentityPrincipalId string = applicationGatewayManagedIdentity.properties.principalId
output containerRegistryManagedIdentityPrincipalId string = containerRegistryManagedIdentity.properties.principalId
// output automationAccountManagedIdentityPrincipalId string = automationAccountManagedIdentity.properties.principalId
// //this one is used to assign user assigned identities for automation account
// output automationAccountManagedIdentityUserId string = automationAccountManagedIdentity.id
