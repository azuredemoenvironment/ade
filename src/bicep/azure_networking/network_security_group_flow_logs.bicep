// Parameters
//////////////////////////////////////////////////
@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The array of Network Security properties.')
param networkSecurityGroupProperties array

@description('The ID of the Storage Account.')
param storageAccountId string

// Resource - Network Security Group Flow Logs
//////////////////////////////////////////////////
resource nsgFlowLog 'Microsoft.Network/networkWatchers/flowLogs@2022-09-01' = [for networkSecurityGroupProperty in networkSecurityGroupProperties: {
  name: 'NetworkWatcher_${location}/${networkSecurityGroupProperty.name}'
  location: location
  properties: {
    targetResourceId: networkSecurityGroupProperty.resourceId
    storageId: storageAccountId
    enabled: true
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        workspaceResourceId: logAnalyticsWorkspaceId
        trafficAnalyticsInterval: 10
      }
    }
    retentionPolicy: {
      days: 7
      enabled: true
    }
    format: {
      type: 'JSON'
      version: 2
    }
  }
}]
