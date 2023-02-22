// Parameters
//////////////////////////////////////////////////
@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('The Base64 encoded certificate for Azure resources.')
param certificateBase64String string

@description('The date of the resource deployment.')
param deploymentDate string = utcNow('yyyy-MM-dd')

@description('The name of the application environment.')
@allowed([
  'dev'
  'prod'
  'test'
])
param environment string

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
var appConfigPurgeProtection = false
var appConfigSku = 'Standard'
var applicationGatewayManagedIdentityPrincipalIdSecretsPermissions = [
  'get'
]
var containerRegistryManagedIdentityPrincipalIdCertificatesPermissions = [
  'get'
]
var containerRegistryManagedIdentityPrincipalIdKeysPermissions = [
  'get'
  'unwrapKey'
  'wrapKey'
]
var containerRegistryManagedIdentityPrincipalIdSecretsPermissions = [
  'get'
]
var keyVaultProperties = {
  name: 'kv-${appEnvironment}-001'
  skuName: 'standard'
  family: 'A'
  enabledForDeployment: true
  enabledForDiskEncryption: true
  enabledForTemplateDeployment: true
  enableSoftDelete: true
  softDeleteRetentionInDays: 7
  enablePurgeProtection: true
  publicNetworkAccess: 'enabled'
}
// var keyVaultName = 'kv-${appEnvironment}-001'
var tags = {
  deploymentDate: deploymentDate
  environment: environment
  owner: ownerName
}

// Existing Resource - Application Insights
//////////////////////////////////////////////////
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: 'appinsights-${appEnvironment}-001'
}

// Existing Resource - Event Hub Authorization Rule
//////////////////////////////////////////////////
resource eventHubNamespaceAuthorizationRule 'Microsoft.EventHub/namespaces/authorizationRules@2021-11-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: 'evh-${appEnvironment}-diagnostics/RootManageSharedAccessKey'
}

// Existing Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: 'log-${appEnvironment}-001'
}

// Existing Resource - Managed Identity - Application Gateway
//////////////////////////////////////////////////
resource applicationGatewayManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  scope: resourceGroup(identityResourceGroupName)
  name: 'id-${appEnvironment}-applicationgateway'
}

// Existing Resource - Managed Identity - Container Registry
//////////////////////////////////////////////////
resource containerRegistryManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  scope: resourceGroup(identityResourceGroupName)
  name: 'id-${appEnvironment}-containerregistry'
}

// Existing Resource - Storage Account - Diagnostics
//////////////////////////////////////////////////
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: replace('sa-${appEnvironment}-diags', '-', '')
}

// Module - App Configuration
//////////////////////////////////////////////////
module appConfigModule './app_config.bicep' = {
  name: 'appConfigDeployment'
  params: {
    appConfigName: appConfigName
    appConfigPurgeProtection: appConfigPurgeProtection
    appConfigSku: appConfigSku
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location: location    
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    storageAccountId: storageAccount.id
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
    certificateBase64String: certificateBase64String
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    keyVaultProperties: keyVaultProperties
    // keyVaultName: keyVaultName
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    resourcePassword: resourcePassword
    storageAccountId: storageAccount.id
    tags: tags
  }
}

// Module - Key Vault - Access Policies
//////////////////////////////////////////////////
module keyVaultAccessPoliciesModule 'key_vault_access_policies.bicep' = {
  name: 'keyVaultAccessPoliciesDeployment'
  params: {
    applicationGatewayManagedIdentityPrincipalId: applicationGatewayManagedIdentity.properties.principalId
    applicationGatewayManagedIdentityPrincipalIdSecretsPermissions: applicationGatewayManagedIdentityPrincipalIdSecretsPermissions
    containerRegistryManagedIdentityPrincipalId: containerRegistryManagedIdentity.properties.principalId
    containerRegistryManagedIdentityPrincipalIdCertificatesPermissions: containerRegistryManagedIdentityPrincipalIdCertificatesPermissions
    containerRegistryManagedIdentityPrincipalIdKeysPermissions: containerRegistryManagedIdentityPrincipalIdKeysPermissions
    containerRegistryManagedIdentityPrincipalIdSecretsPermissions: containerRegistryManagedIdentityPrincipalIdSecretsPermissions
    keyVaultName: keyVaultProperties.name
  }
}
