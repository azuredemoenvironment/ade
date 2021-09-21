param now string = utcNow()
param appConfigName string
param adeApiGatewayVmHostName string
param adeAppApiGatewayAppServiceHostName string

resource appConfigKeyAdeApiGatewayUriAppServices 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  name: '${appConfigName}/ADE:ApiGatewayUri$appservices'
  properties: {
    value: 'https://${adeAppApiGatewayAppServiceHostName}/'
  }
}

resource appConfigKeyAdeApiGatewayUriVirtualMachines 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  name: '${appConfigName}/ADE:ApiGatewayUri$virtualmachines'
  properties: {
    value: 'https://${adeApiGatewayVmHostName}/'
  }
}

resource appConfigKeySentinel 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  name: '${appConfigName}/ADE:Sentinel'
  properties: {
    value: now
  }
}
