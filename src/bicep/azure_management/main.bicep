// Parameters
//////////////////////////////////////////////////
@description('The application environment (workoad, environment, location).')
param appEnvironment string

@description('The selected Azure region for deployment.')
param azureRegion string

@description('The date of the resource deployment.')
param deploymentDate string = utcNow('yyyy-MM-dd')

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

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of the owner of the deployment.')
param ownerName string

// Variables
//////////////////////////////////////////////////
var activityLogDiagnosticSettingsName = 'subscriptionactivitylog'
var applicationInsightsName = 'appinsights-${appEnvironment}-001'
var diagnosticsEventHubName = 'diagnostics'
var diagnosticsEventHubNamespaceName = 'evh-${appEnvironment}-diagnostics'
var diagnosticsStorageAccountName = replace('sa-${appEnvironment}-diags', '-', '')
var initiativeDefinitionName = 'policy-${appEnvironment}-adeinitiative'
var logAnalyticsWorkspaceName = 'log-${appEnvironment}-001'
var logAnalyticsWorkspaceSolutions = [
  {
    name: 'ContainerInsights(${logAnalyticsWorkspaceName})'
    galleryName: 'ContainerInsights'
  }
  {
    name: 'KeyVaultAnalytics(${logAnalyticsWorkspaceName})'
    galleryName: 'KeyVaultAnalytics'
  }
  {
    name: 'VMInsights(${logAnalyticsWorkspaceName})'
    galleryName: 'VMInsights'
  }
]
var tags = {
  deploymentDate: deploymentDate
  owner: ownerName
}

// Module - Log Analytics Workspace
//////////////////////////////////////////////////
module logAnalyticsModule './log_analytics.bicep' = {
  name: 'logAnalyticsDeployment'
  params: {
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    logAnalyticsWorkspaceSolutions: logAnalyticsWorkspaceSolutions
    tags: tags
  }
}

// Module - Storage Account - Diagnostics
//////////////////////////////////////////////////
module storageAccountDiagnosticsModule './storage_account.bicep' = {
  name: 'storageAccountDiagnosticsDeployment'
  params: {
    location: location
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
    diagnosticsStorageAccountName: diagnosticsStorageAccountName
    tags: tags
  }
}

// Module - Event Hub
//////////////////////////////////////////////////
module eventHubDiagnosticsModule './event_hub.bicep' = {
  name: 'eventHubDiagnosticsDeployment'
  params: {
    eventHubName: diagnosticsEventHubName
    eventHubNamespaceName: diagnosticsEventHubNamespaceName
    location: location
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
    tags: tags
  }
}

// Module - Application Insights
//////////////////////////////////////////////////
module applicationInsightsModule './application_insights.bicep' = {
  name: 'applicationInsightsDeployment'
  params: {
    applicationInsightsName: applicationInsightsName
    diagnosticsStorageAccountId: storageAccountDiagnosticsModule.outputs.diagnosticsStorageAccountId
    eventHubNamespaceAuthorizationRuleId: eventHubDiagnosticsModule.outputs.eventHubNamespaceAuthorizationRuleId
    location: location    
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
    tags: tags
  }
}

// Module - Activity Log
//////////////////////////////////////////////////
module activityLogModule './activity_log.bicep' = {
  scope: subscription()
  name: 'activityLogDeployment'
  params: {
    activityLogDiagnosticSettingsName: activityLogDiagnosticSettingsName
    diagnosticsStorageAccountId: storageAccountDiagnosticsModule.outputs.diagnosticsStorageAccountId
    eventHubNamespaceAuthorizationRuleId: eventHubDiagnosticsModule.outputs.eventHubNamespaceAuthorizationRuleId
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
  }
}

// Module - Policy
//////////////////////////////////////////////////
module policyModule './policy.bicep' = {
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
