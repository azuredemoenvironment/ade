// Parameters
//////////////////////////////////////////////////
@description('The name of the Application Gateway Managed Identity.')
param applicationGatewayManagedIdentityName string

@description('The name of the Container Registry Managed Identity.')
param containerRegistryManagedIdentityName string

@description('The location for all resources.')
param location string

@description('The list of resource tags.')
param tags object

@description('The name of the Virtual Machine Managed Identity.')
param virtualMachineManagedIdentityName string

// Resource - Managed Identity - Application Gateway
//////////////////////////////////////////////////
resource applicationGatewayManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: applicationGatewayManagedIdentityName
  location: location
  tags: tags
}

// Resource - Managed Identity - Container Registry
//////////////////////////////////////////////////
resource containerRegistryManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: containerRegistryManagedIdentityName
  location: location
  tags: tags
}

// Resource - Managed Identity - Virtual Machine
//////////////////////////////////////////////////
resource virtualMachineManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: virtualMachineManagedIdentityName
  location: location
  tags: tags
}

// Outputs
//////////////////////////////////////////////////
output applicationGatewayManagedIdentityPrincipalId string = applicationGatewayManagedIdentity.properties.principalId
output containerRegistryManagedIdentityPrincipalId string = containerRegistryManagedIdentity.properties.principalId
output virtualMachineManagedIdentityPrincipalId string = virtualMachineManagedIdentity.properties.principalId
