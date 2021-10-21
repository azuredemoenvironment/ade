// Parameters
//////////////////////////////////////////////////
@description('The array of properties for the ADE App App Services.')
param adeAppAppServices array

@description('The name of the admin user of the Azure Container Registry.')
param containerRegistryName string

@description('The array of ADE App Docker Web Hook Uris.')
param adeAppDockerWebHookUri array

// Variables
//////////////////////////////////////////////////
var location = resourceGroup().location

resource adeAppWebHook 'Microsoft.ContainerRegistry/registries/webhooks@2019-05-01' = [for (adeAppAppService, i) in adeAppAppServices: {
  name: '${containerRegistryName}/${adeAppAppServices[i].adeAppName}'
  location: location
  properties: {
    status: 'enabled'
    scope: adeAppAppServices[i].containerImageName
    actions: [
      'push'
    ]
    serviceUri: adeAppDockerWebHookUri[i]
  }
}]
