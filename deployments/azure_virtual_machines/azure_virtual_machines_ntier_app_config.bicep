param appConfigName string
param backendServices array

resource appConfigKeyVirtualMachineBackingServiceConnectionStrings 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = [for backendService in backendServices: {
  name: '${appConfigName}/ADE:${backendService.name}Uri$virtualmachines'
  properties: {
    value: 'http://localhost:${backendService.port}'
  }
}]
