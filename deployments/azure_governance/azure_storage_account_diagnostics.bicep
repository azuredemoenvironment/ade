// Parameters
//////////////////////////////////////////////////
@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The name of the NSG Flow Logs Storage Account.')
param nsgFlowLogsStorageAccountName string

// Variables
//////////////////////////////////////////////////
var location = resourceGroup().location
var tags = {
  environment: 'production'
  function: 'monitoring and diagnostics'
  costCenter: 'it'
}

// Resource - Storage Account - Nsg Flow Logs
//////////////////////////////////////////////////
resource nsgFlowLogsStorageAccount 'Microsoft.Storage/storageAccounts@2021-01-01' = {
  name: nsgFlowLogsStorageAccountName
  location: location
  tags: tags
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

// Resource - Storage Account - Diagnostic Settings
//////////////////////////////////////////////////
resource nsgFlowLogsStorageAccountDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
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

// Resource - Storage Account - Blob - Diagnostic Settings
//////////////////////////////////////////////////
resource nsgFlowLogsStorageAccountBlobDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
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

// Resource - Storage Account - Table - Diagnostic Settings
//////////////////////////////////////////////////
resource nsgFlowLogsStorageAccountTableDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
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

// Resource - Storage Account - File - Diagnostic Settings
//////////////////////////////////////////////////
resource nsgFlowLogsStorageAccountFileDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
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

// Resource - Storage Account - Queue - Diagnostic Settings
//////////////////////////////////////////////////
resource nsgFlowLogsStorageAccountQueueDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
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
