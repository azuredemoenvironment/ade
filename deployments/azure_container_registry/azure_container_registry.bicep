// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'

// Parameters
//////////////////////////////////////////////////
@description('The user alias and Azure region defined from user input.')
param aliasRegion string

@description('The selected Azure region for deployment.')
param azureRegion string

// Global Variables
//////////////////////////////////////////////////
// Resource Groups
var containerRegistryResourceGroupName = 'rg-ade-${aliasRegion}-containerregistry'
var keyVaultResourceGroupName = 'rg-ade-${aliasRegion}-keyvault'
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
// Resources
var containerRegistryName = replace('acr-ade-${aliasRegion}-001', '-', '')
var keyVaultName = 'kv-ade-${aliasRegion}-001'
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'

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

// Resource Group - Container Registry
//////////////////////////////////////////////////
resource containerRegistryResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: containerRegistryResourceGroupName
  location: azureRegion
}

// Module - Container Registry
//////////////////////////////////////////////////
module containerRegistryModule './azure_container_registry_docker.bicep' = {
  scope: resourceGroup(containerRegistryResourceGroupName)
  name: 'containerRegistryDeployment'
  dependsOn: [
    containerRegistryResourceGroup
  ]
  params: {
    containerRegistryName: containerRegistryName
    containerRegistrySPNObjectID: keyVault.getSecret('containerRegistryObjectId')
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
  }
}
