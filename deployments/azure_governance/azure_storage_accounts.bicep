// Parameters
//////////////////////////////////////////////////
@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The Access Tier of the Storage Account.')
param storageAccountAccessTier string

@description('The Kind of the Storage Account.')
param storageAccountKind string

@description('The name of the Storage Account.')
param storageAccountName string

@description('The SKU of the Storage Account.')
param storageAccountSku string

// Variables
//////////////////////////////////////////////////
var location = resourceGroup().location
var tags = {
  environment: 'production'
  function: 'monitoring and diagnostics'
  costCenter: 'it'
}

// Resource - Storage Account
//////////////////////////////////////////////////
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-01-01' = {
  name: storageAccountName
  location: location
  tags: tags
  kind: storageAccountKind
  sku: {
    name: storageAccountSku
  }
  properties: {
    accessTier: storageAccountAccessTier
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
  scope: storageAccount
  name: '${storageAccount.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
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
resource nsgFlowLogsStorageAccountBlobDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: storageAccount::blobServices
  name: '${storageAccount.name}-blob-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
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
resource nsgFlowLogsStorageAccountTableDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: storageAccount::tableServices
  name: '${storageAccount.name}-table-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
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
resource nsgFlowLogsStorageAccountFileDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: storageAccount::fileServices
  name: '${storageAccount.name}-file-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
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
resource nsgFlowLogsStorageAccountQueueDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: storageAccount::queueServices
  name: '${storageAccount.name}-queue-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
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
