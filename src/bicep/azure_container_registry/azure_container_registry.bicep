// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'

// Parameters
//////////////////////////////////////////////////
@description('The user alias and Azure region defined from user input.')
param aliasRegion string

@description('The selected Azure region for deployment.')
param azureRegion string

@description('The location for all resources.')
param location string = deployment().location

// Global Variables
//////////////////////////////////////////////////
// Resource Groups
var containerRegistryResourceGroupName = 'rg-ade-${aliasRegion}-containerregistry'
var identityResourceGroupName = 'rg-ade-${aliasRegion}-identity'
var keyVaultResourceGroupName = 'rg-ade-${aliasRegion}-keyvault'
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
// Resources
var containerRegistryManagedIdentityName = 'id-ade-${aliasRegion}-containerregistry'
var containerRegistryName = replace('acr-ade-${aliasRegion}-001', '-', '')
var eventHubNamespaceAuthorizationRuleName = 'evh-ade-${aliasRegion}-diagnostics/RootManageSharedAccessKey'
var diagnosticsStorageAccountName = replace('sa-ade-${aliasRegion}-diags', '-', '')
var keyVaultName = 'kv-ade-${aliasRegion}-001'
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'

// Existing Resource - Managed Identity - Container Registry
//////////////////////////////////////////////////
resource containerRegistryManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  scope: resourceGroup(identityResourceGroupName)
  name: containerRegistryManagedIdentityName
}

// Existing Resource - Key Vault
//////////////////////////////////////////////////
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  scope: resourceGroup(keyVaultResourceGroupName)
  name: keyVaultName
}

// Existing Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: logAnalyticsWorkspaceName
}

// Existing Resource - Storage Account - Diagnostics
//////////////////////////////////////////////////
resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-01-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: diagnosticsStorageAccountName
}

// Existing Resource - Event Hub Authorization Rule
//////////////////////////////////////////////////
resource eventHubNamespaceAuthorizationRule 'Microsoft.EventHub/namespaces/authorizationRules@2021-11-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: eventHubNamespaceAuthorizationRuleName
}

// Resource Group - Container Registry
//////////////////////////////////////////////////
resource containerRegistryResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: containerRegistryResourceGroupName
  location: azureRegion
}

// Module - Container Registry - ADE App
//////////////////////////////////////////////////
module containerRegistryModule './azure_container_registry_adeapp.bicep' = {
  scope: resourceGroup(containerRegistryResourceGroupName)
  name: 'containerRegistryDeployment'
  dependsOn: [
    containerRegistryResourceGroup
  ]
  params: {
    containerRegistryName: containerRegistryName
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    // containerRegistryManagedIdentityPrincipalID: containerRegistryManagedIdentity.properties
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
  }
}