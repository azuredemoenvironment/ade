// parameters
param defaultPrimaryRegion string
param azureContainerRegistryName string
param adeAppServiceName string
param adeAppContainerImageName string
param adeAppDockerWebHookUri string

resource adeAppWebHook 'Microsoft.ContainerRegistry/registries/webhooks@2019-05-01' = {
  name: '${azureContainerRegistryName}/${adeAppServiceName}'
  location: defaultPrimaryRegion
  properties: {
    status: 'enabled'
    scope: adeAppContainerImageName
    actions: [
      'push'
    ]
    serviceUri: adeAppDockerWebHookUri
  }
}