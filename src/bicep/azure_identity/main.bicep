// Parameters
//////////////////////////////////////////////////
@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('The date of the resource deployment.')
param deploymentDate string = utcNow('yyyy-MM-dd')

@description('The name of the application environment.')
@allowed([
  'dev'
  'prod'
  'test'
])
param environment string

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of the owner of the deployment.')
param ownerName string

// Variables
//////////////////////////////////////////////////
// Resources
var applicationGatewayManagedIdentityName = 'id-${appEnvironment}-applicationgateway'
var containerRegistryManagedIdentityName = 'id-${appEnvironment}-containerregistry'
var tags = {
  deploymentDate: deploymentDate
  environment: environment
  owner: ownerName
}

// Module - Managed Identity
//////////////////////////////////////////////////
module managedIdentityModule 'managed_identity.bicep' = {
  name: 'identityDeployment'
  params: {
    applicationGatewayManagedIdentityName: applicationGatewayManagedIdentityName
    containerRegistryManagedIdentityName: containerRegistryManagedIdentityName
    location: location
    tags: tags
  }
}
