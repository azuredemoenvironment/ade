// Parameters
//////////////////////////////////////////////////
@description('The array of properties for the ADE App App Services.')
param adeAppAppServices array

@description('The name of the admin user of the Azure Container Registry.')
param containerRegistryName string

@description('The array of ADE App Docker Web Hook Uris.')
param adeAppDockerWebHookUris array

@description('The region location of deployment.')
param location string

// Variables
//////////////////////////////////////////////////

@batchSize(1)
resource adeAppWebHook 'Microsoft.ContainerRegistry/registries/webhooks@2019-05-01' = [for (adeAppAppService, i) in adeAppAppServices: {
  name: '${containerRegistryName}/${adeAppAppService.adeAppAppServiceName}'
  location: location
  properties: {
    status: 'enabled'
    scope: adeAppAppService.containerImageName
    actions: [
      'push'
    ]
    serviceUri: adeAppDockerWebHookUris[i].adeAppDockerWebHookUri
  }
}]
