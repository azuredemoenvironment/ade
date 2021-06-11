param location string = resourceGroup().location
param customerNamePrefix string = 'cust1'

var storageAccountName = 'sa${customerNamePrefix}demo55'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}
