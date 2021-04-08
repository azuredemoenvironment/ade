// parameters
param location string = resourceGroup().location
param aliasRegion string

//variables
var applicationGatewayManagedIdentityName = 'id-ade-${aliasRegion}-agw'
var containerRegistryManagedIdentityName = 'id-ade-${aliasRegion}-acr'
var environmentName = 'production'
var functionName = 'identity'
var costCenterName = 'it'

// resource - managed identity - application gateway
resource applicationGatewayManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: applicationGatewayManagedIdentityName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
}

// resource - managed identity - container registry
resource containerRegistryManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: containerRegistryManagedIdentityName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
}
