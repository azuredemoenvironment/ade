// Parameters
//////////////////////////////////////////////////
@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The name of the Storage Account.')
param diagnosticsStorageAccountName string

@description('The list of Resource tags')
param tags object

// Resource - Storage Account
//////////////////////////////////////////////////
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: diagnosticsStorageAccountName
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
  }
  resource blobServices 'blobServices@2021-09-01' = {
    name: 'default'
  }
  resource tableServices 'tableServices@2021-09-01' = {
    name: 'default'
  }
  resource fileServices 'fileServices@2021-09-01' = {
    name: 'default'
  }
  resource queueServices 'queueServices@2021-09-01' = {
    name: 'default'
  }
}

// Resource - Storage Account - Diagnostic Settings
//////////////////////////////////////////////////
resource storageAccountDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: storageAccount
  name: '${storageAccount.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

// Resource - Storage Account - Blob - Diagnostic Settings
//////////////////////////////////////////////////
resource storageAccountBlobDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: storageAccount::blobServices
  name: '${storageAccount.name}-blob-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

// Resource - Storage Account - Table - Diagnostic Settings
//////////////////////////////////////////////////
resource storageAccountTableDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: storageAccount::tableServices
  name: '${storageAccount.name}-table-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

// Resource - Storage Account - File - Diagnostic Settings
//////////////////////////////////////////////////
resource storageAccountFileDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: storageAccount::fileServices
  name: '${storageAccount.name}-file-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

// Resource - Storage Account - Queue - Diagnostic Settings
//////////////////////////////////////////////////
resource storageAccountQueueDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: storageAccount::queueServices
  name: '${storageAccount.name}-queue-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

// Outputs
//////////////////////////////////////////////////
output diagnosticsStorageAccountId string = storageAccount.id
