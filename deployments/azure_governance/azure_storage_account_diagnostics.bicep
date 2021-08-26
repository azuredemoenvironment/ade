// parameters
param location string
param nsgFlowLogsStorageAccountName string
param logAnalyticsWorkspaceId string

// variables
var environmentName = 'production'
var functionName = 'monitoring and diagnostics'
var costCenterName = 'it'

// resource - storage account - nsg flow logs
resource nsgFlowLogsStorageAccount 'Microsoft.Storage/storageAccounts@2021-01-01' = {
  name: nsgFlowLogsStorageAccountName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  kind: 'StorageV2'
  sku: {
    name: 'Standard_RAGRS'
  }
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
  }
  resource blobServices 'blobServices@2021-01-01' = {
    name: 'default'
  }
  resource tableServices 'tableServices@2021-01-01' = {
    name: 'default'
  }
  resource fileServices 'fileServices@2021-01-01' = {
    name: 'default'
  }
  resource queueServices 'queueServices@2021-01-01' = {
    name: 'default'
  }
}

// resource - storage account - diagnostic settings
resource nsgFlowLogsStorageAccountDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: nsgFlowLogsStorageAccount
  name: '${nsgFlowLogsStorageAccount.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'

    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// resource - storage account - blob - diagnostic settings
resource nsgFlowLogsStorageAccountBlobDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: nsgFlowLogsStorageAccount::blobServices
  name: '${nsgFlowLogsStorageAccount.name}-blob-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'StorageRead'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'StorageWrite'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'StorageDelete'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// resource - storage account - table - diagnostic settings
resource nsgFlowLogsStorageAccountTableDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: nsgFlowLogsStorageAccount::tableServices
  name: '${nsgFlowLogsStorageAccount.name}-table-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'StorageRead'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'StorageWrite'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'StorageDelete'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// resource - storage account - file - diagnostic settings
resource nsgFlowLogsStorageAccountFileDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: nsgFlowLogsStorageAccount::fileServices
  name: '${nsgFlowLogsStorageAccount.name}-file-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'StorageRead'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'StorageWrite'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'StorageDelete'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// resource - storage account - queue - diagnostic settings
resource nsgFlowLogsStorageAccountQueueDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: nsgFlowLogsStorageAccount::queueServices
  name: '${nsgFlowLogsStorageAccount.name}-queue-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'StorageRead'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'StorageWrite'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'StorageDelete'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}
