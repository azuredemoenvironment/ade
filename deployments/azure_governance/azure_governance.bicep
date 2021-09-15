// target scope
targetScope = 'subscription'

// parameters
param defaultPrimaryRegion string
param aliasRegion string
param monitorResourceGroupName string
param appConfigResourceGroupName string
param identityResourceGroupName string
param listOfAllowedLocations array
param listOfAllowedSKUs array

// service name variables
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
var appConfigName = 'appcs-ade-${aliasRegion}-001'
var applicationInsightsName = 'appinsights-ade-${aliasRegion}-001'
var nsgFlowLogsStorageAccountName = replace('saade${aliasRegion}nsgflow', '-', '')
var initiativeDefinitionName = 'policy-ade-${aliasRegion}-adeinitiative'
var applicationGatewayManagedIdentityName = 'id-ade-${aliasRegion}-agw'
var containerRegistryManagedIdentityName = 'id-ade-${aliasRegion}-acr'

// module - log analytics workspace
module logAnalyticsModule './azure_log_analytics.bicep' = {
  scope: resourceGroup(monitorResourceGroupName)
  name: 'logAnalyticsDeployment'
  params: {
    location: defaultPrimaryRegion
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}

// module - app config
module appConfigModule './azure_app_config.bicep' = {
  scope: resourceGroup(appConfigResourceGroupName)
  name: 'appConfigDeployment'
  params: {
    location: defaultPrimaryRegion
    appConfigName: appConfigName
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
  }
}

// module - application insights
module applicationInsightsModule './azure_application_insights.bicep' = {
  scope: resourceGroup(monitorResourceGroupName)
  name: 'applicationInsightsDeployment'
  params: {
    location: defaultPrimaryRegion
    applicationInsightsName: applicationInsightsName
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
  }
}

// module - app config - application insights
module appConfigApplicationInsightsModule './azure_app_config_application_insights.bicep' = {
  scope: resourceGroup(appConfigResourceGroupName)
  name: 'appConfigApplicationInsightsDeployment'
  params: {
    appConfigName: appConfigModule.outputs.appConfigName
    applicationInsightsConnectionString: applicationInsightsModule.outputs.applicationInsightsConnectionString
    applicationInsightsInstrumentationKey: applicationInsightsModule.outputs.applicationInsightsInstrumentationKey
  }
}

// module - storage account diagnostics
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
module activityLogModule './azure_activity_log.bicep' = {
  scope: subscription()
  name: 'activityLogDeployment'
  params: {
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
  }
}

// module - policy
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
module identityModule 'azure_identity.bicep' = {
  scope: resourceGroup(identityResourceGroupName)
  name: 'identityDeployment'
  params: {
    location: defaultPrimaryRegion
    applicationGatewayManagedIdentityName: applicationGatewayManagedIdentityName
    containerRegistryManagedIdentityName: containerRegistryManagedIdentityName
  }
}
