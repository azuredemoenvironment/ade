// Parameters
//////////////////////////////////////////////////
@description('The name of the App Configuration instance.')
param appConfigName string

@description('Array of backend services for ADE App.')
param backendServices array

// Resource - App Configuration Key Values - Virtual Machine Backend Service Connection Strings
resource appConfigKeyVirtualMachineBackendServiceConnectionStrings 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = [for backendService in backendServices: {
  name: '${appConfigName}/ADE:${backendService.name}Uri$virtualmachines'
  properties: {
    value: 'http://localhost:${backendService.port}'
  }
}]
