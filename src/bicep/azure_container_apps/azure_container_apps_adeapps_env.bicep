// Parameters
//////////////////////////////////////////////////
@description('The location for all resources.')
param location string

@description('The Client Id of the Log Analytics Workspace.')
param logAnalyticsWorkspaceCustomerId string

@description('The Shared Key of the Log Analytics Workspace.')
param logAnalyticsWorkspacePrimarySharedKey string

@description('The Environemnt name that hosts the Container App.')
param contanierAppsEnvironmentName string

// Variables
//////////////////////////////////////////////////
var tags = {
  environment: 'production'
  function: 'containerRegistry'
  costCenter: 'it'
}

// Resource - Azure Container App Environment
resource contanierAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: contanierAppsEnvironmentName
  location: location
  tags: tags
  properties: {
    type: 'managed'
    internalLoadBalancerEnabled: false
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspaceCustomerId
        sharedKey: logAnalyticsWorkspacePrimarySharedKey
      }
    }
  }
}
output id string = contanierAppsEnvironment.id

