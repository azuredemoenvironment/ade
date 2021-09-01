// Target Scope - This option sets the scope of the deployment to the subscription.
targetScope = 'subscription'

// Parameters
@description('Parameter for the default primary Azure region. Currently set to East US. Defined in azure_governance_parameters.json.')
param defaultPrimaryRegion string

@description('Parameter for the user alias and default primary Azure region defined from user input. Defined in azure_governance_parameters.json.')
param aliasRegion string

@description('Parameter for the list of allowed locations for the Log Analytics Workspace. Defined in azure_governance_parameters.json.')
param listOfAllowedLocations array

@description('Parameter for the list of allowed virtual machine SKUs. Defined in azure_governance_parameters.json.')
param listOfAllowedSKUs array

// Variables
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
var identityResourceGroupName = 'rg-ade-${aliasRegion}-identity'

// Module - Log Anlytics
// Variables
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
// Module Deployment
module logAnalyticsModule './azure_log_analytics.bicep' = {
  scope: resourceGroup(monitorResourceGroupName)
  name: 'logAnalyticsDeployment'
  params: {
    location: defaultPrimaryRegion
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}

// Module - Data Collection Rule
// Variables
var dataCollectionRuleName = 'dcr-ade-${aliasRegion}-vminsights'
// Module Deployment
module dataCollectionRuleModule './azure_data_collection_rule.bicep' = {
  scope: resourceGroup(monitorResourceGroupName)
  name: 'dataCollectionRuleDeployment'
  params: {
    location: defaultPrimaryRegion
    dataCollectionRuleName: dataCollectionRuleName
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
  }
}

// Module - Application Insights
// Variables
var applicationInsightsName = 'appinsights-ade-${aliasRegion}-001'
// Module Deployment
module applicationInsightsModule './azure_application_insights.bicep' = {
  scope: resourceGroup(monitorResourceGroupName)
  name: 'applicationInsightsDeployment'
  params: {
    location: defaultPrimaryRegion
    applicationInsightsName: applicationInsightsName
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
  }
}

// Module - Storage Account - Diagnostics
// Variables
var nsgFlowLogsStorageAccountName = replace('saade${aliasRegion}nsgflow', '-', '')
// Module Deployment
module storageAccountDiagnosticsModule './azure_storage_account_diagnostics.bicep' = {
  scope: resourceGroup(monitorResourceGroupName)
  name: 'storageAccountDiagnosticsDeployment'
  params: {
    location: defaultPrimaryRegion
    nsgFlowLogsStorageAccountName: nsgFlowLogsStorageAccountName
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
  }
}

// Module - Activity Log
// Module Deployment
module activityLogModule './azure_activity_log.bicep' = {
  scope: subscription()
  name: 'activityLogDeployment'
  params: {
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
  }
}

// Module - Policy
// Variables
var initiativeDefinitionName = 'policy-ade-${aliasRegion}-adeinitiative'
// Module Deployment
module policyModule './azure_policy.bicep' = {
  scope: subscription()
  name: 'policyDeployment'
  params: {
    defaultPrimaryRegion: defaultPrimaryRegion
    initiativeDefinitionName: initiativeDefinitionName
    listOfAllowedLocations: listOfAllowedLocations
    listOfAllowedSKUs: listOfAllowedSKUs
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
  }
}

// Module - Identity
// Variables
var managedIdentityNames = [
  'id-ade-${aliasRegion}-agw'
  'id-ade-${aliasRegion}-acr'
]
// Module Deployment
module identityModule 'azure_identity.bicep' = {
  scope: resourceGroup(identityResourceGroupName)
  name: 'identityDeployment'
  params: {
    location: defaultPrimaryRegion
    managedIdentityNames: managedIdentityNames
  }
}
