// parameters
param location string
param nsgFlowLogsStorageAccountId string
param logAnalyticsWorkspaceId string
param azureBastionSubnetNSGId string
param managementSubnetNSGId string
param nTierWebSubnetNSGId string
param nTierAppSubnetNSGId string
param vmssSubnetNSGId string
param clientServicesSubnetNSGId string

// resource - nsg flow log - azure bastion subnet nsg
resource azureBastionSubnetNSGFlowLog 'Microsoft.Network/networkWatchers/flowLogs@2020-11-01' = {
  name: 'NetworkWatcher_${location}/bastion'
  location: location
  properties: {
    targetResourceId: azureBastionSubnetNSGId
    storageId: nsgFlowLogsStorageAccountId
    enabled: true
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        workspaceId: logAnalyticsWorkspaceId
        trafficAnalyticsInterval: 30
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
}

// resource - nsg flow log - management subnet nsg
resource managementSubnetNSGFlowLog 'Microsoft.Network/networkWatchers/flowLogs@2020-11-01' = {
  name: 'NetworkWatcher_${location}/management'
  location: location
  properties: {
    targetResourceId: managementSubnetNSGId
    storageId: nsgFlowLogsStorageAccountId
    enabled: true
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        workspaceId: logAnalyticsWorkspaceId
        trafficAnalyticsInterval: 30
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
}

// resource - nsg flow log - nTierWeb subnet nsg
resource nTierWebSubnetNSGFlowLog 'Microsoft.Network/networkWatchers/flowLogs@2020-11-01' = {
  name: 'NetworkWatcher_${location}/nTierWeb'
  location: location
  properties: {
    targetResourceId: nTierWebSubnetNSGId
    storageId: nsgFlowLogsStorageAccountId
    enabled: true
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        workspaceId: logAnalyticsWorkspaceId
        trafficAnalyticsInterval: 30
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
}

// resource - nsg flow log - nTierApp subnet nsg
resource nTierAppSubnetNSGFlowLog 'Microsoft.Network/networkWatchers/flowLogs@2020-11-01' = {
  name: 'NetworkWatcher_${location}/nTierApp'
  location: location
  properties: {
    targetResourceId: nTierAppSubnetNSGId
    storageId: nsgFlowLogsStorageAccountId
    enabled: true
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        workspaceId: logAnalyticsWorkspaceId
        trafficAnalyticsInterval: 30
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
}

// resource - nsg flow log - vmss subnet nsg
resource vmssSubnetNSGFlowLog 'Microsoft.Network/networkWatchers/flowLogs@2020-11-01' = {
  name: 'NetworkWatcher_${location}/vmss'
  location: location
  properties: {
    targetResourceId: vmssSubnetNSGId
    storageId: nsgFlowLogsStorageAccountId
    enabled: true
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        workspaceId: logAnalyticsWorkspaceId
        trafficAnalyticsInterval: 30
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
}

// resource - nsg flow log - clientServices subnet nsg
resource clientServicesSubnetNSGFlowLog 'Microsoft.Network/networkWatchers/flowLogs@2020-11-01' = {
  name: 'NetworkWatcher_${location}/clientServices'
  location: location
  properties: {
    targetResourceId: clientServicesSubnetNSGId
    storageId: nsgFlowLogsStorageAccountId
    enabled: true
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        workspaceId: logAnalyticsWorkspaceId
        trafficAnalyticsInterval: 30
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
}
