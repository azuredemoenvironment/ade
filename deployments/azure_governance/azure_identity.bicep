// Parameters
//////////////////////////////////////////////////
param applicationGatewayManagedIdentityName string
param containerRegistryManagedIdentityName string

// Variables
//////////////////////////////////////////////////
var location = resourceGroup().location
var tags = {
  environment: 'production'
  function: 'identity'
  costCenter: 'it'
}

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
output applicationGatewayManagedIdentityPrincipalId string = applicationGatewayManagedIdentity.properties.principalId
output containerRegistryManagedIdentityPrincipalId string = containerRegistryManagedIdentity.properties.principalId
