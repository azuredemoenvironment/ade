// Parameters
//////////////////////////////////////////////////
@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('The date of the resource deployment.')
param deploymentDate string = utcNow('yyyy-MM-dd')

@description('The name of the Identity Resource Group.')
param identityResourceGroupName string

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of the Management Resource Group.')
param managementResourceGroupName string

@description('The name of the owner of the deployment.')
param ownerName string

// Variables
//////////////////////////////////////////////////
var acrPullRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var containerRegistryName = replace('acr-${appEnvironment}-001', '-', '')
var tags = {
  deploymentDate: deploymentDate
  owner: ownerName
}

// Existing Resource - Event Hub Authorization Rule
//////////////////////////////////////////////////
resource eventHubNamespaceAuthorizationRule 'Microsoft.EventHub/namespaces/authorizationRules@2021-11-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: 'evh-${appEnvironment}-diagnostics/RootManageSharedAccessKey'
}

// Existing Resource - Managed Identity - Container Registry
//////////////////////////////////////////////////
resource containerRegistryManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  scope: resourceGroup(identityResourceGroupName)
  name: 'id-${appEnvironment}-containerregistry'
}

// Existing Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: 'log-${appEnvironment}-001'
}

// Existing Resource - Storage Account - Diagnostics
//////////////////////////////////////////////////
resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: replace('sa-${appEnvironment}-diags', '-', '')
}

// Module - Container Registry
//////////////////////////////////////////////////
module containerRegistryModule './container_registry.bicep' = {
  name: 'containerRegistryDeployment'
  params: {
    acrPullRoleDefinitionId: acrPullRoleDefinitionId
    containerRegistryName: containerRegistryName
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    containerRegistryManagedIdentityPrincipalID: containerRegistryManagedIdentity.properties.principalId
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    tags: tags
  }
}
