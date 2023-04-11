// Parameters
//////////////////////////////////////////////////
@description('The array of App Service Docker Web Hook Uris.')
param appDockerWebHookUris array

@description('The array of properties for the App Services.')
param appServices array

@description('The region location of deployment.')
param location string

// Variables
//////////////////////////////////////////////////
@batchSize(1)
resource webHook 'Microsoft.ContainerRegistry/registries/webhooks@2021-09-01' = [for (appService, i) in appServices: {
  name: '${appService.containerRegistryName}/${appService.name}'
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
