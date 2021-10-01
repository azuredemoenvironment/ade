// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'

// Parameters
//////////////////////////////////////////////////
@description('The user alias and Azure region defined from user input.')
param aliasRegion string

@description('The Azure Active Directory Tenant ID.')
param azureActiveDirectoryTenantID string

@description('The Azure Active Directory User ID.')
param azureActiveDirectoryUserID string

@description('The selected Azure region for deployment.')
param azureRegion string

@description('The list of allowed locations for resource deployment. Used in Azure Policy module.')
param listOfAllowedLocations array

@description('The list of allowed virtual machine SKUs. Used in Azure Policy module.')
param listOfAllowedSKUs array = [
  'Standard_B1ls'
  'Standard_B1ms'
  'Standard_B1s'
  'Standard_B2ms'
  'Standard_B2s'
  'Standard_B4ms'
  'Standard_B4s'
  'Standard_D2s_v3'
  'Standard_D4s_v3'
]

// Global Variables
//////////////////////////////////////////////////
// Resource Groups
var appConfigResourceGroupName = 'rg-ade-${aliasRegion}-appconfiguration'
var identityResourceGroupName = 'rg-ade-${aliasRegion}-identity'
var keyVaultResourceGroupName = 'rg-ade-${aliasRegion}-keyvault'
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
// Resources
var activityLogDiagnosticSettingsName = 'subscriptionactivitylog'
var appConfigName = 'appcs-ade-${aliasRegion}-001'
var applicationGatewayManagedIdentityName = 'id-ade-${aliasRegion}-applicationgateway'
var applicationInsightsName = 'appinsights-ade-${aliasRegion}-001'
var containerRegistryManagedIdentityName = 'id-ade-${aliasRegion}-containerregistry'
var containerRegistrySpnName = 'spn-ade-$aliasRegion-acr'
var deploymentScriptManagedIdentityName = 'id-ade-${aliasRegion}-deploymentscript'
var githubActionsSpnName = 'spn-ade-$aliasRegion-gha'
var initiativeDefinitionName = 'policy-ade-${aliasRegion}-adeinitiative'
var keyVaultName = 'kv-ade-${aliasRegion}-001'
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
var nsgFlowLogsStorageAccountName = replace('saade${aliasRegion}nsgflow', '-', '')
var restApiSpnName = 'spn-ade-$aliasRegion-restapi'

// Resource Group - App Configuration
//////////////////////////////////////////////////
resource appConfigResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: appConfigResourceGroupName
  location: azureRegion
}

// Resource Group - Identity
//////////////////////////////////////////////////
resource identityResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: identityResourceGroupName
  location: azureRegion
}

// Resource Group - Key Vault
//////////////////////////////////////////////////
resource keyVaultResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: keyVaultResourceGroupName
  location: azureRegion
}

// Resource Group - Monitor
//////////////////////////////////////////////////
resource monitorResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: monitorResourceGroupName
  location: azureRegion
}

// Module - Log Analytics Workspace
//////////////////////////////////////////////////
module logAnalyticsModule './azure_log_analytics.bicep' = {
  scope: resourceGroup(monitorResourceGroupName)
  name: 'logAnalyticsDeployment'
  dependsOn: [
    monitorResourceGroup
  ]
  params: {
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}

// Module - App Configuration
//////////////////////////////////////////////////
module appConfigModule './azure_app_configuration.bicep' = {
  scope: resourceGroup(appConfigResourceGroupName)
  name: 'appConfigDeployment'
  dependsOn: [
    appConfigResourceGroup
  ]
  params: {
    appConfigName: appConfigName
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
  }
}

// Module - Application Insights
//////////////////////////////////////////////////
module applicationInsightsModule './azure_application_insights.bicep' = {
  scope: resourceGroup(monitorResourceGroupName)
  name: 'applicationInsightsDeployment'
  dependsOn: [
    monitorResourceGroup
  ]
  params: {
    applicationInsightsName: applicationInsightsName
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
  }
}

// Module - App Configuration - Application Insights
//////////////////////////////////////////////////
module appConfigApplicationInsightsModule './azure_app_configuration_application_insights.bicep' = {
  scope: resourceGroup(appConfigResourceGroupName)
  name: 'appConfigApplicationInsightsDeployment'
  params: {
    appConfigName: appConfigModule.outputs.appConfigName
    applicationInsightsConnectionString: applicationInsightsModule.outputs.applicationInsightsConnectionString
    applicationInsightsInstrumentationKey: applicationInsightsModule.outputs.applicationInsightsInstrumentationKey
  }
}

// Module - Storage Account Diagnostics
//////////////////////////////////////////////////
module storageAccountDiagnosticsModule './azure_storage_account_diagnostics.bicep' = {
  scope: resourceGroup(monitorResourceGroupName)
  name: 'storageAccountDiagnosticsDeployment'
  dependsOn: [
    monitorResourceGroup
  ]
  params: {
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
    nsgFlowLogsStorageAccountName: nsgFlowLogsStorageAccountName
  }
}

// Module - Activity Log
//////////////////////////////////////////////////
module activityLogModule './azure_activity_log.bicep' = {
  scope: subscription()
  name: 'activityLogDeployment'
  params: {
    activityLogDiagnosticSettingsName: activityLogDiagnosticSettingsName
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
  }
}

// Module - Policy
//////////////////////////////////////////////////
module policyModule './azure_policy.bicep' = {
  scope: subscription()
  name: 'policyDeployment'
  params: {
    azureRegion: azureRegion
    initiativeDefinitionName: initiativeDefinitionName
    listOfAllowedLocations: listOfAllowedLocations
    listOfAllowedSKUs: listOfAllowedSKUs
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
  }
}

// Module - Indentity
//////////////////////////////////////////////////
module identityModule 'azure_identity.bicep' = {
  scope: resourceGroup(identityResourceGroupName)
  name: 'identityDeployment'
  dependsOn: [
    identityResourceGroup
  ]
  params: {
    applicationGatewayManagedIdentityName: applicationGatewayManagedIdentityName
    containerRegistryManagedIdentityName: containerRegistryManagedIdentityName
    containerRegistrySpnName: containerRegistrySpnName
    deploymentScriptManagedIdentityName: deploymentScriptManagedIdentityName
    githubActionsSpnName: githubActionsSpnName
    restApiSpnName: restApiSpnName
  }
}

// Module - Key Vault
//////////////////////////////////////////////////
module keyVaultModule './azure_key_vault.bicep' = {
  scope: resourceGroup(keyVaultResourceGroupName)
  name: 'logAnalyticsDeployment'
  dependsOn: [
    keyVaultResourceGroup
  ]
  params: {
    applicationGatewayManagedIdentityPrincipalID: identityModule.outputs.applicationGatewayManagedIdentityPrincipalId
    azureActiveDirectoryTenantID: azureActiveDirectoryTenantID
    azureActiveDirectoryUserID: azureActiveDirectoryUserID
    containerRegistryManagedIdentityPrincipalID: identityModule.outputs.containerRegistryManagedIdentityPrincipalId
    keyVaultName: keyVaultName
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
    servicePrincipals: identityModule.outputs.servicePrincipals
  }
}
