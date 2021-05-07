// parameters
param location string
param applicationGatewayManagedIdentityName string
param containerRegistryManagedIdentityName string

//variables
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
