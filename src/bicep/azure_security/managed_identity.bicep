// Parameters
//////////////////////////////////////////////////
@description('The name of the Application Gateway Managed Identity.')
param applicationGatewayManagedIdentityName string

@description('The name of the Container Registry Managed Identity.')
param containerRegistryManagedIdentityName string

@description('The location for all resources.')
param location string

@description('The list of resource tags')
param tags object

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

// Outputs
//////////////////////////////////////////////////
output applicationGatewayManagedIdentityPrincipalId string = applicationGatewayManagedIdentity.properties.principalId
output containerRegistryManagedIdentityPrincipalId string = containerRegistryManagedIdentity.properties.principalId
