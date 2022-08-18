// Parameters
//////////////////////////////////////////////////
@description('The Id of the Acr Pull Role Definition.')
param acrPullRoleDefinitionId string

@description('The name of the Container Registry.')
param containerRegistryName string

@description('The ID of the Diagnostics Storage Account.')
param diagnosticsStorageAccountId string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The Principal ID of the Container Registry Managed Identity.')
param containerRegistryManagedIdentityPrincipalID string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The list of Resource tags')
param tags object

// Resource - Container Registry
//////////////////////////////////////////////////
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' = {
  name: containerRegistryName
  location: location
  tags: tags
  sku: {
    name: 'Premium'
  }
  properties: {
    adminUserEnabled: true
  }
}

// Resource - Container Registry - Diagnostics
//////////////////////////////////////////////////
resource containerRegistryDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${containerRegistry.name}-diagnostics'
  scope: containerRegistry
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'ContainerRegistryRepositoryEvents'
        enabled: true
      }
      {
        category: 'ContainerRegistryLoginEvents'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// Resource - Role Assignment - Acr Pull
//////////////////////////////////////////////////
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, acrPullRoleDefinitionId, containerRegistryManagedIdentityPrincipalID)
  properties: {
    roleDefinitionId: acrPullRoleDefinitionId
    principalId: containerRegistryManagedIdentityPrincipalID
    principalType: 'User'
  }
}

// Outputs
//////////////////////////////////////////////////
output containerRegistryURL string = containerRegistry.properties.loginServer
output containerRegistryCredentials string = first(listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords).value
