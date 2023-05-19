// Parameters
//////////////////////////////////////////////////
@description('The name of the key.')
param keyName string

@description('The value of the key.')
param keyValue string

// Resource - App Configuration - Application Insights Connection String
//////////////////////////////////////////////////
resource appConfigKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = {
  name: keyName
  properties: {
    value: keyValue
  }
}
