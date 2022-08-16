// Parameters
//////////////////////////////////////////////////
@description('The application environment (workoad, environment, location).')
param appEnvironment string

@description('The Base64 encoded certificate for Azure resources.')
param certificateBase64String string

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

@description('The password for Azure resources.')
@secure()
param resourcePassword string

// Variables
//////////////////////////////////////////////////
// Resources
var appConfigName = 'appcs-${appEnvironment}-001'
var keyVaultName = 'kv-${appEnvironment}-001'
var logAnalyticsWorkspaceName = 'log-${appEnvironment}-001'
var tags = {
  deploymentDate: deploymentDate
  owner: ownerName
}

// Existing Resource - Application Insights
//////////////////////////////////////////////////
var applicationInsightsName = 'appinsights-${appEnvironment}-001'
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: applicationInsightsName
}

// Existing Resource - Event Hub Authorization Rule
//////////////////////////////////////////////////
var eventHubNamespaceAuthorizationRuleName = 'evh-${appEnvironment}-diagnostics/RootManageSharedAccessKey'
resource eventHubNamespaceAuthorizationRule 'Microsoft.EventHub/namespaces/authorizationRules@2021-11-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: eventHubNamespaceAuthorizationRuleName
}

// Existing Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: logAnalyticsWorkspaceName
}

// Existing Resource - Managed Identity - Application Gateway
//////////////////////////////////////////////////
var applicationGatewayManagedIdentityName = 'id-${appEnvironment}-applicationgateway'
resource applicationGatewayManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  scope: resourceGroup(identityResourceGroupName)
  name: applicationGatewayManagedIdentityName
}

// Existing Resource - Managed Identity - Container Registry
//////////////////////////////////////////////////
var containerRegistryManagedIdentityName = 'id-${appEnvironment}-containerregistry'
resource containerRegistryManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  scope: resourceGroup(identityResourceGroupName)
  name: containerRegistryManagedIdentityName
}

// Existing Resource - Storage Account - Diagnostics
//////////////////////////////////////////////////
var diagnosticsStorageAccountName = replace('sa-${appEnvironment}-diags', '-', '')
resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: diagnosticsStorageAccountName
}

// Module - App Configuration
//////////////////////////////////////////////////
module appConfigModule './app_config.bicep' = {
  name: 'appConfigDeployment'
  params: {
    appConfigName: appConfigName
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location: location    
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    tags: tags
  }
}

// Module - App Configuration - Application Insights
//////////////////////////////////////////////////
module appConfigApplicationInsightsModule './app_config_application_insights.bicep' = {
  name: 'appConfigApplicationInsightsDeployment'
  params: {
    appConfigName: appConfigModule.outputs.appConfigName
    applicationInsightsConnectionString: applicationInsights.properties.ConnectionString
  }
}

// Module - Key Vault
//////////////////////////////////////////////////
module keyVaultModule './key_vault.bicep' = {
  name: 'keyVaultDeployment'
  params: {
    applicationGatewayManagedIdentityPrincipalID: applicationGatewayManagedIdentity.properties.principalId
    certificateBase64String: certificateBase64String
    containerRegistryManagedIdentityPrincipalID: containerRegistryManagedIdentity.properties.principalId
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    keyVaultName: keyVaultName
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    resourcePassword: resourcePassword
    tags: tags
  }
}
