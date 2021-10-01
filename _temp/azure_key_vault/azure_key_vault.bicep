// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'

// Parameters
//////////////////////////////////////////////////
@description('The selected Azure region for deployment.')
param azureRegion string

@description('The user alias and Azure region defined from user input.')
param aliasRegion string

@description('The Azure Active Directory Tenant ID.')
param azureActiveDirectoryTenantID string

@description('The Azure Active Directory User ID.')
param azureActiveDirectoryUserID string

@description('The Service Principal Name ID of the Application Gateway Managed Identity.')
param applicationGatewayManagedIdentitySPNID string

@description('The Service Principal Name ID of the Container Registry Managed Identity.')
param containerRegistryManagedIdentitySPNID string

@description('The Password of the Container Registry Service Principal.')
param containerRegistrySPNPassword string

@description('The Application ID of the Container Registry Service Principal.')
param containerRegistrySPNAppID string

@description('The Object ID of the Container Registry Service Principal.')
param containerRegistrySPNObjectID string

@description('The Password of the GitHub Actions Service Principal.')
param githubActionsSPNPassword string

@description('The Application ID of the GitHub Actions Service Principal.')
param githubActionsSPNAppID string

@description('The Password of the REST API Service Principal.')
param restAPISPNPassword string

@description('The Application ID of the REST API Service Principal.')
param restAPISPNAppID string

// Global Variables
//////////////////////////////////////////////////
// Resource Groups
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
var keyVaultResourceGroupName = 'rg-ade-${aliasRegion}-keyvault'
// Resources
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
var keyVaultName = 'kv-ade-${aliasRegion}-001'

// Existing Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: logAnalyticsWorkspaceName
}

// Resource Group - Key Vault
//////////////////////////////////////////////////
resource keyVaultResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: keyVaultResourceGroupName
  location: azureRegion
}

// Module - Key Vault
//////////////////////////////////////////////////
module keyVaultModule './azure_key_vault_vault.bicep' = {
  scope: resourceGroup(keyVaultResourceGroupName)
  name: 'logAnalyticsDeployment'
  params: {
    azureActiveDirectoryTenantID: azureActiveDirectoryTenantID
    azureActiveDirectoryUserID: azureActiveDirectoryUserID
    applicationGatewayManagedIdentitySPNID: applicationGatewayManagedIdentitySPNID
    containerRegistryManagedIdentitySPNID: containerRegistryManagedIdentitySPNID
    containerRegistrySPNPassword: containerRegistrySPNPassword
    containerRegistrySPNAppID: containerRegistrySPNAppID
    containerRegistrySPNObjectID: containerRegistrySPNObjectID
    githubActionsSPNPassword: githubActionsSPNPassword
    githubActionsSPNAppID: githubActionsSPNAppID
    restAPISPNPassword: restAPISPNPassword
    restAPISPNAppID: restAPISPNAppID
    keyVaultName: keyVaultName
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
  }
}
