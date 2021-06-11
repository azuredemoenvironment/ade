// parameters
param defaultPrimaryRegion string
param azureContainerRegistryName string
param adeAppFrontEndAppServiceName string
param adeAppApiGatewayAppServiceName string
param adeAppUserServiceAppServiceName string
param adeAppDataIngestorServiceAppServiceName string
param adeAppDataReporterServiceAppServiceName string
param adeAppFrontEndAppServiceImageName string
param adeAppApiGatewayAppServiceImageName string
param adeAppUserServiceAppServiceImageName string
param adeAppDataIngestorServiceAppServiceImageName string
param adeAppDataReporterServiceAppServiceImageName string
param adeAppFrontEndAppServiceUri string
param adeAppApiGatewayAppServiceUri string
param adeAppUserServiceAppServiceUri string
param adeAppDataIngestorServiceAppServiceUri string
param adeAppDataReporterServiceAppServiceUri string

resource adeAppFrontEndAppWebHook 'Microsoft.ContainerRegistry/registries/webhooks@2019-05-01' = {
  name: '${azureContainerRegistryName}/${adeAppFrontEndAppServiceName}'
  location: defaultPrimaryRegion
  properties: {
    status: 'enabled'
    scope: adeAppFrontEndAppServiceImageName
    actions: [
      'push'
    ]
    serviceUri: adeAppFrontEndAppServiceUri
  }
}

resource adeAppApiGatewayAppWebHook 'Microsoft.ContainerRegistry/registries/webhooks@2019-05-01' = {
  name: '${azureContainerRegistryName}/${adeAppApiGatewayAppServiceName}'
  location: defaultPrimaryRegion
  dependsOn: [
    adeAppFrontEndAppWebHook
  ]
  properties: {
    status: 'enabled'
    scope: adeAppApiGatewayAppServiceImageName
    actions: [
      'push'
    ]
    serviceUri: adeAppApiGatewayAppServiceUri
  }
}

resource adeAppUserServiceAppWebHook 'Microsoft.ContainerRegistry/registries/webhooks@2019-05-01' = {
  name: '${azureContainerRegistryName}/${adeAppUserServiceAppServiceName}'
  location: defaultPrimaryRegion
  dependsOn: [
    adeAppApiGatewayAppWebHook
  ]
  properties: {
    status: 'enabled'
    scope: adeAppUserServiceAppServiceImageName
    actions: [
      'push'
    ]
    serviceUri: adeAppUserServiceAppServiceUri
  }
}

resource adeAppDataIngestorAppWebHook 'Microsoft.ContainerRegistry/registries/webhooks@2019-05-01' = {
  name: '${azureContainerRegistryName}/${adeAppDataIngestorServiceAppServiceName}'
  location: defaultPrimaryRegion
  dependsOn: [
    adeAppUserServiceAppWebHook
  ]
  properties: {
    status: 'enabled'
    scope: adeAppDataIngestorServiceAppServiceImageName
    actions: [
      'push'
    ]
    serviceUri: adeAppDataIngestorServiceAppServiceUri
  }
}

resource adeAppDataReporterAppWebHook 'Microsoft.ContainerRegistry/registries/webhooks@2019-05-01' = {
  name: '${azureContainerRegistryName}/${adeAppDataReporterServiceAppServiceName}'
  location: defaultPrimaryRegion
  dependsOn: [
    adeAppDataIngestorAppWebHook
  ]
  properties: {
    status: 'enabled'
    scope: adeAppDataReporterServiceAppServiceImageName
    actions: [
      'push'
    ]
    serviceUri: adeAppDataReporterServiceAppServiceUri
  }
}
