// parameters
param location string
param sourceAddressPrefix string
param vmDiagnosticsStorageAccountName string
param nsgFlowLogsStorageAccountName string

// variables
var environmentName = 'production'
var functionName = 'monitoring and diagnostics'
var costCenterName = 'it'

// resource - storage account - virtual machine diagnostics
resource vmDiagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-01-01' = {
  name: vmDiagnosticsStorageAccountName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  kind: 'StorageV2'
  sku: {
    name: 'Standard_RAGRS'
    tier: 'Standard'
  }
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: [
        {
          value: sourceAddressPrefix
        }
      ]
      defaultAction: 'Deny'
    }
  }
}

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
    tier: 'Standard'
  }
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
  }
}
