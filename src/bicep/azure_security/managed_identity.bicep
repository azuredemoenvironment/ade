// Parameters
//////////////////////////////////////////////////
@description('The location for all resources.')
param location string

@description('The array of Managed Identities.')
param managedIdentities array

@description('The list of resource tags.')
param tags object

// Resource - Managed Identity
//////////////////////////////////////////////////
resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = [for (managedIdentity, i) in managedIdentities: {
  name: managedIdentity.name
  location: location
  tags: tags
}]

// Outputs
//////////////////////////////////////////////////
output managedIdentityPrincipalIds array = [for (managedIdentity, i) in managedIdentities: {
  managedIdentityPrincipalId: identity[i].properties.principalId
}]
