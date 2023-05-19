// Parameters
//////////////////////////////////////////////////
@description('The array of App Configuration keys.')
param appConfigKeys array

// Resource - App Configuration - Key Values - Virtual Machine Backend Services
//////////////////////////////////////////////////
resource virtualMachineBackendServiceConnectionStrings 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = [for appConfigKey in appConfigKeys: {
  name: appConfigKey.keyName
  properties: {
    value: appConfigKey.keyValue
  }
}]
