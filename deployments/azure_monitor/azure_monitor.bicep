// parameters
param location string = resourceGroup().location
param aliasRegion string
param sourceAddressPrefix string

// variables - log analytics
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'

// variables - application insights
var applicationInsightsName = 'appinsights-ade-${aliasRegion}-001'

// variables - storage account diagnostics
var nsgFlowLogsStorageAccountName = replace('saade${aliasRegion}nsgflow', '-', '')

// module - log analytics
module logAnalyticsModule './azure_log_analytics.bicep' = {
  name: 'logAnalyticsDeployment'
  params: {
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}

// module - application insights
module applicationInsightsModule './azure_application_insights.bicep' = {
  name: 'applicationInsightsDeployment'
  params: {
    location: location
    applicationInsightsName: applicationInsightsName
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
  }
}

// module - storage account diagnostics
module storageAccountDiagnosticsModule './azure_storage_account_diagnostics.bicep' = {
  name: 'storageAccountDiagnosticsDeployment'
  params: {
    location: location
    nsgFlowLogsStorageAccountName: nsgFlowLogsStorageAccountName
  }
}

// module - activity log
module activityLogModule './azure_activity_log.bicep' = {
  name: 'activityLogDeployment'
  scope: subscription()
  params: {
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
  }
}
