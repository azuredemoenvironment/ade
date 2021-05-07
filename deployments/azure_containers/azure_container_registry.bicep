// parameters
param defaultPrimaryRegion string
param logAnalyticsWorkspaceId string
param azureContainerRegistryName string
param acrServicePrincipalClientId string
param roleDefinitionId string

// variables
var environmentName = 'production'
var functionName = 'containerRegistry'
var costCenterName = 'it'

// resource - azure container registry
resource azureContainerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' = {
  name: azureContainerRegistryName
  location: defaultPrimaryRegion
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  sku: {
    name: 'Premium'
  }
  properties: {
    adminUserEnabled: true
  }
}

// resource - azure container registry - diagnostics
resource azureContainerRegistryDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${azureContainerRegistry.name}-diagnostics'
  scope: azureContainerRegistry
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

// resource - role asignment - acr pull
resource azureContainerRegistryRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: azureContainerRegistry
  name: guid(resourceGroup().id, roleDefinitionId, acrServicePrincipalClientId)
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: acrServicePrincipalClientId
    principalType: 'ServicePrincipal'
  }
}
