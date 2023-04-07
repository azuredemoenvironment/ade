// Parameters
//////////////////////////////////////////////////
@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('The Base64 encoded certificate for Azure resources.')
param certificateBase64String string

@description('The current date.')
param currentDate string = utcNow('yyyy-MM-dd')

@description('The name of the application environment.')
@allowed([
  'dev'
  'prod'
  'test'
])
param environment string

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
var tags = {
  deploymentDate: currentDate
  environment: environment
  owner: ownerName
}

// Variables - Managed Identity
//////////////////////////////////////////////////
var applicationGatewayManagedIdentityName = 'id-${appEnvironment}-applicationgateway'
var containerRegistryManagedIdentityName = 'id-${appEnvironment}-containerregistry'

// Variables - App Configuration
//////////////////////////////////////////////////
var appConfigName = 'appcs-${appEnvironment}'
var appConfigPurgeProtection = false
var appConfigSku = 'Standard'

// Variables - Key Vault
//////////////////////////////////////////////////
var certificateSecretName = 'certificate'
var keyVaultName = 'kv-${appEnvironment}'
var keyVaultProperties = {
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
var resourcePasswordSecretName = 'resourcePassword'

// Variables - Key Vault - Access Policies
//////////////////////////////////////////////////
var applicationGatewayManagedIdentityPrincipalIdSecretsPermissions = ['get']
var containerRegistryManagedIdentityPrincipalIdCertificatesPermissions = ['get']
var containerRegistryManagedIdentityPrincipalIdKeysPermissions = ['get', 'unwrapKey', 'wrapKey']
var containerRegistryManagedIdentityPrincipalIdSecretsPermissions = ['get']

// Variables - Existing Resources
//////////////////////////////////////////////////
var applicationInsightsName = 'appinsights-${appEnvironment}'
var eventHubNamespaceAuthorizationRuleName = 'RootManageSharedAccessKey'
var eventHubNamespaceName = 'evhns-${appEnvironment}-diagnostics'
var logAnalyticsWorkspaceName = 'log-${appEnvironment}'
var storageAccountName = replace('sa-diag-${uniqueString(subscription().subscriptionId)}', '-', '')

// Existing Resource - Application Insights
//////////////////////////////////////////////////
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: applicationInsightsName
}

// Existing Resource - Event Hub Authorization Rule
//////////////////////////////////////////////////
resource eventHubNamespaceAuthorizationRule 'Microsoft.EventHub/namespaces/authorizationRules@2021-11-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: '${eventHubNamespaceName}/${eventHubNamespaceAuthorizationRuleName}'
}

// Existing Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: logAnalyticsWorkspaceName
}

// Existing Resource - Storage Account - Diagnostics
//////////////////////////////////////////////////
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: storageAccountName
}

// Module - Managed Identity
//////////////////////////////////////////////////
module managedIdentityModule 'managed_identity.bicep' = {
  name: 'identityDeployment'
  params: {
    applicationGatewayManagedIdentityName: applicationGatewayManagedIdentityName
    containerRegistryManagedIdentityName: containerRegistryManagedIdentityName
    location: location
    tags: tags
  }
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
    certificateSecretName: certificateSecretName
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    keyVaultProperties: keyVaultProperties
    keyVaultName: keyVaultName
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    resourcePassword: resourcePassword
    resourcePasswordSecretName: resourcePasswordSecretName
    storageAccountId: storageAccount.id
    tags: tags
  }
}

// Module - Key Vault - Access Policies
//////////////////////////////////////////////////
module keyVaultAccessPoliciesModule 'key_vault_access_policies.bicep' = {
  name: 'keyVaultAccessPoliciesDeployment'
  params: {
    applicationGatewayManagedIdentityPrincipalId: managedIdentityModule.outputs.applicationGatewayManagedIdentityPrincipalId
    applicationGatewayManagedIdentityPrincipalIdSecretsPermissions: applicationGatewayManagedIdentityPrincipalIdSecretsPermissions
    containerRegistryManagedIdentityPrincipalId: managedIdentityModule.outputs.containerRegistryManagedIdentityPrincipalId
    containerRegistryManagedIdentityPrincipalIdCertificatesPermissions: containerRegistryManagedIdentityPrincipalIdCertificatesPermissions
    containerRegistryManagedIdentityPrincipalIdKeysPermissions: containerRegistryManagedIdentityPrincipalIdKeysPermissions
    containerRegistryManagedIdentityPrincipalIdSecretsPermissions: containerRegistryManagedIdentityPrincipalIdSecretsPermissions
    keyVaultName: keyVaultModule.outputs.keyVaultName
  }
}
