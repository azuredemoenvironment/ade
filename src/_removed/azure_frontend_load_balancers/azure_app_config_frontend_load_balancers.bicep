// Parameters
//////////////////////////////////////////////////
@description('The Host name of the  App Api Gateway App Service.')
param adeAppApiGatewayAppServiceHostName string

@description('The Host name of the  App Api Gateway Virtual Machine.')
param adeAppApiGatewayVmHostName string

@description('The name of the App Configuration instance.')
param appConfigName string

@description('Function to generate the current time.')
param currentTime string = utcNow()

// Resource - App Configuration Key Values -  App Api Gateway App Service Uri
//////////////////////////////////////////////////
resource appConfigKeyAdeAppApiGatewayAppServicesUri 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  name: '${appConfigName}/ADE:ApiGatewayUri$appservices'
  properties: {
    value: 'https://${adeAppApiGatewayAppServiceHostName}'
  }
}

// Resource - App Configuration Key Values -  App Api Gateway App Service Uri
//////////////////////////////////////////////////
resource appConfigKeyAdeAppApiGatewayVmUri 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  name: '${appConfigName}/ADE:ApiGatewayUri$virtualmachines'
  properties: {
    value: 'https://${adeAppApiGatewayVmHostName}'
  }
}
