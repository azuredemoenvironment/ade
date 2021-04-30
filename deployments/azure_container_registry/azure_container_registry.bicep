// parameters
param location string = resourceGroup().location
param aliasRegion string
param acrServicePrincipalClientId string

// variables
var azureContainerRegistryName = replace('acr-ade-${aliasRegion}-001', '-', '')
var environmentName = 'production'
var functionName = 'containerRegistry'
var costCenterName = 'it'

// variables - role assignment definition for acr pull - https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#acrpull
var roleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

// existing resource
// log analytics
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(monitorResourceGroupName)
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
  name: guid(resourceGroup().id, roleDefinitionId, acrServicePrincipalClientId)
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: acrServicePrincipalClientId
    principalType: 'ServicePrincipal'
  }
}
