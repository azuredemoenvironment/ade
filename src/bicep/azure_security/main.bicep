// Parameters
//////////////////////////////////////////////////
@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('The Base64 encoded certificate for Azure resources.')
param certificateBase64String string

@description('The current date.')
param currentDate string = utcNow('yyyy-MM-dd')

@description('Function to generate the current time.')
param currentTime string = utcNow()

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

@description('The value for Root Domain Name.')
param rootDomainName string

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
var frontDoorManagedIdentityName = 'id-${appEnvironment}-frontdoor'
var virtualMachineManagedIdentityName = 'id-${appEnvironment}-virtualmachine'
var managedIdentities = [
  {
    name: applicationGatewayManagedIdentityName
  }
  {
    name: containerRegistryManagedIdentityName
  }
  {
    name: frontDoorManagedIdentityName
  }
  {
    name: virtualMachineManagedIdentityName
  }
]

// Variables - App Configuration
//////////////////////////////////////////////////
var appConfigName = 'appcs-${appEnvironment}'
var appConfigPurgeProtection = false
var appConfigSku = 'Standard'

// Variables - App Configuration - Keys (Public URIs)
//////////////////////////////////////////////////
var apiGatewayAppServiceHostName = 'ade-apigateway-app.${rootDomainName}'
var apiGatewayVmHostName = 'ade-apigateway-vm.${rootDomainName}'
var apiGatewayVmssHostName = 'ade-apigateway-vmss.${rootDomainName}'
var appConfigurationKeysPublic = [
  {
    keyName: '${appConfigModule.outputs.appConfigName}/ADE:ApiGatewayUri$appservices'
    keyValue: 'https://${apiGatewayAppServiceHostName}'
  }
  {
    keyName: '${appConfigModule.outputs.appConfigName}/ADE:ApiGatewayUri$virtualmachines'
    keyValue: 'https://${apiGatewayVmHostName}'
  }
  {
    keyName: '${appConfigModule.outputs.appConfigName}/ADE:ApiGatewayUri$virtualmachinescalesets'
    keyValue: 'https://${apiGatewayVmssHostName}'
  }
]

// Variables - App Configuration - Keys (Private URIs)
//////////////////////////////////////////////////
var apiGatewayAppServiceName = replace('app-${appEnvironment}-ade-apigateway', '-', '')
var appConfigurationKeysPrivate = [
  {
    keyName: '${appConfigModule.outputs.appConfigName}/ApplicationInsights:ConnectionString'
    keyValue: applicationInsights.properties.ConnectionString
  }
  {
    keyName: '${appConfigModule.outputs.appConfigName}/ASPNETCORE_ENVIRONMENT'
    keyValue: 'Development'
  }
  {
    keyName: '${appConfigModule.outputs.appConfigName}/Ade:Sentinel'
    keyValue: currentTime
  }  
  
  {
    keyName: '${appConfigModule.outputs.appConfigName}/Ade:FrontendUri$appservices'
    keyValue: 'https://${frontendAppServiceName}.azurewebsites.net'
  }
  {
    keyName: '${appConfigModule.outputs.appConfigName}/Ade:ApiGatewayUri$appservices'
    keyValue: 'https://${apiGatewayAppServiceName}.azurewebsites.net'
  }  
  {
    keyName: '${appConfigModule.outputs.appConfigName}/Ade:DataIngestorServiceUri$appservices'
    keyValue: 'https://${dataIngestorAppServiceName}.azurewebsites.net'
  }
  {
    keyName: '${appConfigModule.outputs.appConfigName}/Ade:DataReporterServiceUri$appservices'
    keyValue: 'https://${dataReporterAppServiceName}.azurewebsites.net'
  }
  {
    keyName: '${appConfigModule.outputs.appConfigName}/Ade:UserServiceUri$appservices'
    keyValue: 'https://${userServiceAppServiceName}.azurewebsites.net'
  }
  {
    keyName: '${appConfigModule.outputs.appConfigName}/Ade:EventIngestorServiceUri$appservices'
    keyValue: 'https://${eventIngestorAppServiceName}.azurewebsites.net'
  }  
  {
    keyName: '${appConfigModule.outputs.appConfigName}/Ade:DataIngestorServiceUri$virtualmachines'
    keyValue: 'http://localhost:5000'
  }
  {
    keyName: '${appConfigModule.outputs.appConfigName}/Ade:DataReporterServiceUri$virtualmachines'
    keyValue: 'http://localhost:5001'
  }
  {
    keyName: '${appConfigModule.outputs.appConfigName}/Ade:UserServiceUri$virtualmachines'
    keyValue: 'http://localhost:5002'
  }
  {
    keyName: '${appConfigModule.outputs.appConfigName}/Ade:EventIngestorServiceUri$virtualmachines'
    keyValue: 'http://localhost:5003'
  }
  {
    keyName: '${appConfigModule.outputs.appConfigName}/Ade:DataIngestorServiceUri$virtualmachinescalesets'
    keyValue: 'http://localhost:5000'
  }
  {
    keyName: '${appConfigModule.outputs.appConfigName}/Ade:DataReporterServiceUri$virtualmachinescalesets'
    keyValue: 'http://localhost:5001'
  }
  {
    keyName: '${appConfigModule.outputs.appConfigName}/Ade:UserServiceUri$virtualmachinescalesets'
    keyValue: 'http://localhost:5002'
  }
  {
    keyName: '${appConfigModule.outputs.appConfigName}/Ade:EventIngestorServiceUri$virtualmachinescalesets'
    keyValue: 'http://localhost:5003'
  }
]
var dataIngestorAppServiceName = replace('app-${appEnvironment}-ade-dataingestorservice', '-', '')
var dataReporterAppServiceName = replace('app-${appEnvironment}-ade-datareporterservice', '-', '')
var eventIngestorAppServiceName = replace('app-${appEnvironment}-ade-eventingestorservice', '-', '')
var frontendAppServiceName = replace('app-${appEnvironment}-ade-frontend', '-', '')
var userServiceAppServiceName = replace('app-${appEnvironment}-ade-userservice', '-', '')


// Variables - Key Vault
//////////////////////////////////////////////////
var certificateSecretName = 'certificate'
var keyVaultName = replace('kv-${appEnvironment}', '-', '')
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
var keyVaultAccessPolicies = [
  {
    objectId: managedIdentityModule.outputs.managedIdentityPrincipalIds[0].managedIdentityPrincipalId
    permissions: {
      secrets: ['get']
    }
  }
  {
    objectId: 'f8daea97-62e7-4026-becf-13c2ea98e8b4'
    permissions: {
      certificates: ['get']
      secrets: ['get']
    }
  }
  {
    objectId: managedIdentityModule.outputs.managedIdentityPrincipalIds[1].managedIdentityPrincipalId
    permissions: {
      certificates: ['get']
      keys: ['get', 'unwrapKey', 'wrapKey']
      secrets: ['get']
    }
  }
  {
    objectId: managedIdentityModule.outputs.managedIdentityPrincipalIds[2].managedIdentityPrincipalId
      permissions: {
      certificates: ['get']
      secrets: ['get']
    }
  }
]

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

// Existing Resource - Storage Account - Diagnostics
//////////////////////////////////////////////////
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: storageAccountName
}

// Module - Managed Identity
//////////////////////////////////////////////////
module managedIdentityModule 'managed_identity.bicep' = {
  name: 'identityDeployment'
  params: {
    location: location
    managedIdentities: managedIdentities
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

// Module - App Configuration - Keys (Public URIs)
//////////////////////////////////////////////////
module appConfigurationKeysPublicModule 'app_config_keys.bicep' = {
  name: 'appConfigurationKeysPublicDeployment'
  params: {
    appConfigKeys: appConfigurationKeysPublic
  }
}

// Module - App Configuration - Keys (Private URIs)
//////////////////////////////////////////////////
module appConfigurationKeysPrivateModule 'app_config_keys.bicep' = {
  name: 'appConfigurationKeysPrivateDeployment'
  params: {
    appConfigKeys: appConfigurationKeysPrivate
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
    keyVaultAccessPolicies: keyVaultAccessPolicies
    keyVaultName: keyVaultModule.outputs.keyVaultName
  }
}
