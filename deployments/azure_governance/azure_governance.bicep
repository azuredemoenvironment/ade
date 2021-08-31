// target scope
targetScope = 'subscription'

// parameters
param defaultPrimaryRegion string
param aliasRegion string
param monitorResourceGroupName string
param identityResourceGroupName string
param listOfAllowedLocations array
param listOfAllowedSKUs array

// module - log analytics workspace
// variables
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
// module deployment
module logAnalyticsModule './azure_log_analytics.bicep' = {
  scope: resourceGroup(monitorResourceGroupName)
  name: 'logAnalyticsDeployment'
  params: {
    location: defaultPrimaryRegion
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}

// module - application insights
// variables
var applicationInsightsName = 'appinsights-ade-${aliasRegion}-001'
// module deployment
module applicationInsightsModule './azure_application_insights.bicep' = {
  scope: resourceGroup(monitorResourceGroupName)
  name: 'applicationInsightsDeployment'
  params: {
    location: defaultPrimaryRegion
    applicationInsightsName: applicationInsightsName
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
  }
}

// module - storage account diagnostics
// variables
var nsgFlowLogsStorageAccountName = replace('saade${aliasRegion}nsgflow', '-', '')
// module deployment
module storageAccountDiagnosticsModule './azure_storage_account_diagnostics.bicep' = {
  scope: resourceGroup(monitorResourceGroupName)
  name: 'storageAccountDiagnosticsDeployment'
  params: {
    location: defaultPrimaryRegion
    nsgFlowLogsStorageAccountName: nsgFlowLogsStorageAccountName
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
  }
}

// module - activity log
// module deployment
module activityLogModule './azure_activity_log.bicep' = {
  scope: subscription()
  name: 'activityLogDeployment'
  params: {
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
  }
}

// module - policy
// variables
var initiativeDefinitionName = 'policy-ade-${aliasRegion}-adeinitiative'
// module deployment
module policyModule './azure_policy.bicep' = {
  scope: subscription()
  name: 'policyDeployment'
  params: {
    defaultPrimaryRegion: defaultPrimaryRegion
    listOfAllowedLocations: listOfAllowedLocations
    listOfAllowedSKUs: listOfAllowedSKUs
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
    initiativeDefinitionName: initiativeDefinitionName
  }
}

// module - indentity
// variables
var applicationGatewayManagedIdentityName = 'id-ade-${aliasRegion}-agw'
var containerRegistryManagedIdentityName = 'id-ade-${aliasRegion}-acr'
// module deployment
module identityModule 'azure_identity.bicep' = {
  scope: resourceGroup(identityResourceGroupName)
  name: 'identityDeployment'
  params: {
    location: defaultPrimaryRegion
    applicationGatewayManagedIdentityName: applicationGatewayManagedIdentityName
    containerRegistryManagedIdentityName: containerRegistryManagedIdentityName
  }
}
