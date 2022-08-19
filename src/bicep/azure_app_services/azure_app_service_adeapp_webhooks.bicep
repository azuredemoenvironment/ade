// Parameters
//////////////////////////////////////////////////
@description('The array of Ade App Docker Web Hook Uris.')
param appDockerWebHookUris array

@description('The array of properties for the Ade App App Services.')
param appServices array

@description('The name of the admin user of the Azure Container Registry.')
param containerRegistryName string

@description('The region location of deployment.')
param location string

// Variables
//////////////////////////////////////////////////

@batchSize(1)
resource webHook 'Microsoft.ContainerRegistry/registries/webhooks@2021-09-01' = [for (appService, i) in appServices: {
  name: '${containerRegistryName}/${appService.adeAppServiceName}'
  location: location
  properties: {
    status: 'enabled'
    scope: appService.containerImageName
    actions: [
      'push'
    ]
    serviceUri: appDockerWebHookUris[i].adeAppDockerWebHookUri
  }
}]
