// Parameters
@description('Parameter for the location of resources. Defined in azure_governance.bicep.')
param location string

@description('Parameter for the names of the Managed Identities. Defined in azure_governance.bicep.')
param managedIdentityNames array

// Variables
var environmentName = 'production'
var functionName = 'identity'
var costCenterName = 'it'

// Resource - Managed Identity
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = [for managedIdentityName in managedIdentityNames: {
  name: managedIdentityName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
}]
