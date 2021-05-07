// parameters
param location string = resourceGroup().location
param aliasRegion string

// TODO: these should probably be dedicated templates, but for now we're just trying to get them stubbed in

// module - app service frontend
module frontendAppServiceModule './azure_app_service_ade_app.bicep' = {
  name: 'frontendAppServiceDeployment'
  params: {
    location: location
    aliasRegion: aliasRegion
    appServiceAppName: 'frontend'
  }
}

// module - app service apigateway
module apigatewayAppServiceModule './azure_app_service_ade_app.bicep' = {
  name: 'apigatewayAppServiceDeployment'
  params: {
    location: location
    aliasRegion: aliasRegion
    appServiceAppName: 'apigateway'
  }
}

// module - app service dataingestorservice
module dataingestorserviceAppServiceModule './azure_app_service_ade_app.bicep' = {
  name: 'dataingestorserviceAppServiceDeployment'
  params: {
    location: location
    aliasRegion: aliasRegion
    appServiceAppName: 'dataingestorservice'
  }
}

// module - app service datareporterservice
module datareporterserviceAppServiceModule './azure_app_service_ade_app.bicep' = {
  name: 'datareporterserviceAppServiceDeployment'
  params: {
    location: location
    aliasRegion: aliasRegion
    appServiceAppName: 'datareporterservice'
  }
}

// module - app service userservice
module userserviceAppServiceModule './azure_app_service_ade_app.bicep' = {
  name: 'userserviceAppServiceDeployment'
  params: {
    location: location
    aliasRegion: aliasRegion
    appServiceAppName: 'userservice'
  }
}
