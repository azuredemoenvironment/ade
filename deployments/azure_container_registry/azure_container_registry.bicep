// parameters
param location string = resourceGroup().location
param aliasRegion string
param containerRegistrySPNObjectID string

// variables
var azureContainerRegistryName = replace('acr-ade-${aliasRegion}-001', '-', '')
var roleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // role assignment definition for acr pull - https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#acrpull
var environmentName = 'production'
var functionName = 'containerRegistry'
var costCenterName = 'it'

// existing resources
// variables
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
// resource log analytics workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: logAnalyticsWorkspaceName
}

// resource - azure container registry
resource azureContainerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' = {
  name: azureContainerRegistryName
  location: location
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
    workspaceId: logAnalyticsWorkspace.id
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
  name: guid(resourceGroup().id, roleDefinitionId, containerRegistrySPNObjectID)
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: containerRegistrySPNObjectID
    principalType: 'ServicePrincipal'
  }
}

// outputs
output azureContainerRegistryURL string = azureContainerRegistry.properties.loginServer
output azureContainerRegistryCredentials string = first(listCredentials(azureContainerRegistry.id, azureContainerRegistry.apiVersion).passwords).value
