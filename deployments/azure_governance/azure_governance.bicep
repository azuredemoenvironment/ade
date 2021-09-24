// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'

// Parameters
//////////////////////////////////////////////////
@description('The selected Azure region for deployment.')
param azureRegion string

@description('The user alias and Azure region defined from user input.')
param aliasRegion string

@description('The list of allowed locations for resource deployment. Used in Azure Policy module.')
param listOfAllowedLocations array

@description('The list of allowed virtual machine SKUs. Used in Azure Policy module.')
param listOfAllowedSKUs array

// Global Variables
//////////////////////////////////////////////////
// Resource Groups
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
var appConfigResourceGroupName = 'rg-ade-${aliasRegion}-appconfiguration'
var identityResourceGroupName = 'rg-ade-${aliasRegion}-identity'
// Resources
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
var appConfigName = 'appcs-ade-${aliasRegion}-001'
var applicationInsightsName = 'appinsights-ade-${aliasRegion}-001'
var nsgFlowLogsStorageAccountName = replace('saade${aliasRegion}nsgflow', '-', '')
var activityLogDiagnosticSettingsName = 'subscriptionactivitylog'
var initiativeDefinitionName = 'policy-ade-${aliasRegion}-adeinitiative'
var applicationGatewayManagedIdentityName = 'id-ade-${aliasRegion}-agw'
var containerRegistryManagedIdentityName = 'id-ade-${aliasRegion}-acr'

// Resource Group - Monitor
//////////////////////////////////////////////////
resource monitorResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: monitorResourceGroupName
  location: azureRegion
}

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

// Module - Log Analytics Workspace
//////////////////////////////////////////////////
module logAnalyticsModule './azure_log_analytics.bicep' = {
  scope: resourceGroup(monitorResourceGroupName)
  name: 'logAnalyticsDeployment'
  params: {
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}

// Module - App Configuration
//////////////////////////////////////////////////
module appConfigModule './azure_app_configuration.bicep' = {
  scope: resourceGroup(appConfigResourceGroupName)
  name: 'appConfigDeployment'
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
  params: {
    nsgFlowLogsStorageAccountName: nsgFlowLogsStorageAccountName
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
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
    listOfAllowedLocations: listOfAllowedLocations
    listOfAllowedSKUs: listOfAllowedSKUs
    initiativeDefinitionName: initiativeDefinitionName
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
  }
}

// module - indentity
//////////////////////////////////////////////////
module identityModule 'azure_identity.bicep' = {
  scope: resourceGroup(identityResourceGroupName)
  name: 'identityDeployment'
  params: {
    applicationGatewayManagedIdentityName: applicationGatewayManagedIdentityName
    containerRegistryManagedIdentityName: containerRegistryManagedIdentityName
  }
}
