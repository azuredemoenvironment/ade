// Parameters
//////////////////////////////////////////////////
@description('The array of App Configuration keys.')
param appConfigKeys array

// Resource - App Configuration - Key
//////////////////////////////////////////////////
resource key 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = [for (appConfigKey, i) in appConfigKeys: {
  name: appConfigKey.keyName
  properties: {
    value: appConfigKey.keyValue
  }
}]
