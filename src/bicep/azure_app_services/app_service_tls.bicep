// Parameters
//////////////////////////////////////////////////
@description('The array of App Service Tls settings.')
param appServiceTlsSettings array

// Resource - App Service - Custom Domain
//////////////////////////////////////////////////
resource customDomain 'Microsoft.Web/sites/hostNameBindings@2022-03-01' = [for (appServiceTlsSetting, i) in appServiceTlsSettings: {
  name: '${appServiceTlsSetting.appServiceName}/${appServiceTlsSetting.applicationHostName}'
  properties: {
    hostNameType: appServiceTlsSetting.hostNameType
    sslState: appServiceTlsSetting.sslState
    customHostNameDnsRecordType: appServiceTlsSetting.customHostNameDnsRecordType
    siteName: appServiceTlsSetting.appServiceName
    thumbprint: appServiceTlsSetting.thumbprint
  }
}]
