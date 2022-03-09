// Parameters
//////////////////////////////////////////////////
@description('The name of the Container Registry.')
param containerRegistryName string

// @description('The Principal ID of the Container Registry Managed Identity.')
// @secure()
// param containerRegistryManagedIdentityPrincipalID string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

// Variables
//////////////////////////////////////////////////
// var acrPullRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // Role Assignment Definition for ACR Pull - https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#acrpull
var tags = {
  environment: 'production'
  function: 'containerRegistry'
  costCenter: 'it'
}

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
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'ContainerRegistryRepositoryEvents'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'ContainerRegistryLoginEvents'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// Resource - Role Asignment - Acr Pull
//////////////////////////////////////////////////
// resource containerRegistryRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
//   scope: containerRegistry
//   name: guid(resourceGroup().id, acrPullRoleDefinitionId, containerRegistryManagedIdentityPrincipalID)
//   properties: {
//     roleDefinitionId: acrPullRoleDefinitionId
//     principalId: containerRegistryManagedIdentityPrincipalID
//     principalType: 'User'
//   }
// }

// Outputs
//////////////////////////////////////////////////
output containerRegistryURL string = containerRegistry.properties.loginServer
output containerRegistryCredentials string = first(listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords).value
