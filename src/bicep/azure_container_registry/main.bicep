// Parameters
//////////////////////////////////////////////////
@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('The current date.')
param currentDate string = utcNow('yyyy-MM-dd')

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of the Management Resource Group.')
param managementResourceGroupName string

@description('The name of the owner of the deployment.')
param ownerName string

@description('The name of the Security Resource Group.')
param securityResourceGroupName string

// Variables
//////////////////////////////////////////////////
var tags = {
  deploymentDate: currentDate
  owner: ownerName
}

// Variables - Container Registry
//////////////////////////////////////////////////
var acrPullRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var containerRegistryName = replace('acr-${appEnvironment}-001', '-', '')
var containerRegistryPrincipalIdType = 'ServicePrincipal'
var containerRegistryProperties = {
  name: containerRegistryName
  skuName: 'Premium'
  adminUserEnabled: true
}

// Variables - Existing Resources
//////////////////////////////////////////////////
var containerRegistryManagedIdentityName = 'id-${appEnvironment}-containerregistry'
var eventHubNamespaceAuthorizationRuleName = 'RootManageSharedAccessKey'
var eventHubNamespaceName = 'evhns-${appEnvironment}-diagnostics'
var logAnalyticsWorkspaceName = 'log-${appEnvironment}'
var storageAccountName = replace('sa-diag-${uniqueString(subscription().subscriptionId)}', '-', '')

// Existing Resource - Event Hub Authorization Rule
//////////////////////////////////////////////////
resource eventHubNamespaceAuthorizationRule 'Microsoft.EventHub/namespaces/authorizationRules@2022-10-01-preview' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: '${eventHubNamespaceName}/${eventHubNamespaceAuthorizationRuleName}'
}

// Existing Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: logAnalyticsWorkspaceName
}

// Existing Resource - Managed Identity - Container Registry
//////////////////////////////////////////////////
resource containerRegistryManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup(securityResourceGroupName)
  name: containerRegistryManagedIdentityName
}

// Existing Resource - Storage Account - Diagnostics
//////////////////////////////////////////////////
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: storageAccountName
}

// Module - Container Registry
//////////////////////////////////////////////////
module containerRegistryModule './container_registry.bicep' = {
  name: 'containerRegistryDeployment'
  params: {
    acrPullRoleDefinitionId: acrPullRoleDefinitionId
    containerRegistryManagedIdentityPrincipalID: containerRegistryManagedIdentity.properties.principalId
    containerRegistryPrincipalIdType: containerRegistryPrincipalIdType
    containerRegistryProperties: containerRegistryProperties
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    storageAccountId: storageAccount.id
    tags: tags
  }
}
