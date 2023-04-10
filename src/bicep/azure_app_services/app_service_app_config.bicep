// Parameters
//////////////////////////////////////////////////
@description('The array of properties for the App Services.')
param appServices array

// Resource - App Configuration - Key Values - App Service Connection String
//////////////////////////////////////////////////
resource appConfigKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = [for (appService, i) in appServices: {
  name: '${appService.keyValueName}'
  properties: {
    value: 'https://${appService.name}.azurewebsites.net'
  }
}]
