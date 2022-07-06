// Parameters
//////////////////////////////////////////////////
@description('The array of properties for the ADE App App Services.')
param adeAppAppServices array

@description('The name of the App Configuration instance.')
param appConfigName string

// Resource - App Configuration - Key Virtual Machine Backing Service Connection String
//////////////////////////////////////////////////
resource appConfigKeyVirtualMachineBackingServiceConnectionStrings 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = [for (adeAppAppService, i) in adeAppAppServices: {
  name: '${appConfigName}/ADE:${adeAppAppService.adeAppName}Uri$appservices'
  properties: {
    value: 'https://${adeAppAppService.adeAppAppServiceName}.azurewebsites.net'
  }
}]
