// target scope
targetScope = 'subscription'

// parameters
param defaultPrimaryRegion string
param aliasRegion string
param monitorResourceGroupName string
param containerRegistryResourceGroupName string
param acrServicePrincipalClientId string

// existing resources
// variables
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
// resource - log analytics workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: logAnalyticsWorkspaceName
}

// module - azure container registry
// variables
var azureContainerRegistryName = replace('acr-ade-${aliasRegion}-001', '-', '')
// variables - role assignment definition for acr pull - https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#acrpull
var roleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
// module deployment
module azureContainerRegistryModule 'azure_container_registry.bicep' = {
  scope: resourceGroup(containerRegistryResourceGroupName)
  name: 'azureContainerRegistryDeployment'
  params: {
    defaultPrimaryRegion: defaultPrimaryRegion
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    acrServicePrincipalClientId: acrServicePrincipalClientId
    azureContainerRegistryName: azureContainerRegistryName
    roleDefinitionId: roleDefinitionId
  }
}
