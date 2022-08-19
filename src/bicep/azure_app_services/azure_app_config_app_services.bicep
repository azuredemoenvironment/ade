// Parameters
//////////////////////////////////////////////////
@description('The name of the App Configuration instance.')
param appConfigName string

@description('The array of properties for the Ade App App Services.')
param appServices array

// Resource - App Configuration - Key Virtual Machine Backing Service Connection String
//////////////////////////////////////////////////
resource appConfigKeyVirtualMachineBackingServiceConnectionStrings 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = [for (appService, i) in appServices: {
  name: '${appConfigName}/Ade:${appService.appShortName}Uri$appservices'
  properties: {
    value: 'https://${appService.name}.azurewebsites.net'
  }
}]
