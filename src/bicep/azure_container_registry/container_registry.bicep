// Parameters
//////////////////////////////////////////////////
@description('The Id of the Acr Pull Role Definition.')
param acrPullRoleDefinitionId string

@description('The Principal ID of the Container Registry Managed Identity.')
param containerRegistryManagedIdentityPrincipalID string

@description('The properties of the Container Registry.')
param containerRegistryProperties object

@description('The principal ID type of the Container Registry.')
param containerRegistryPrincipalIdType string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The ID of the Storage Account.')
param storageAccountId string

@description('The list of resource tags.')
param tags object

// Resource - Container Registry
//////////////////////////////////////////////////
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: containerRegistryProperties.name
  location: location
  tags: tags
  sku: {
    name: containerRegistryProperties.skuName
  }
  properties: {
    adminUserEnabled: containerRegistryProperties.adminUserEnabled
  }
}

// Resource - Container Registry - Diagnostics
//////////////////////////////////////////////////
resource containerRegistryDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${containerRegistry.name}-diagnostics'
  scope: containerRegistry
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: storageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        categoryGroup: 'allLogs'
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

// Resource - Role Assignment - Acr Pull
//////////////////////////////////////////////////
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, acrPullRoleDefinitionId, containerRegistryManagedIdentityPrincipalID)
  properties: {
    roleDefinitionId: acrPullRoleDefinitionId
    principalId: containerRegistryManagedIdentityPrincipalID
    principalType: containerRegistryPrincipalIdType
  }
}
