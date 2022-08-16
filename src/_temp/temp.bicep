// Module - Storage Account - NSG Flow Logs
//////////////////////////////////////////////////
module storageAccountNsgFlowLogsModule './azure_storage_accounts.bicep' = {
  name: 'storageAccountNsgFlowLogsDeployment'
  params: {
    location: location
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
    storageAccountName: nsgFlowLogsStorageAccount.name
  }
}
