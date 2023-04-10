// Parameters
//////////////////////////////////////////////////
@description('The array of App Service Tls settings.')
param appServiceTlsSettings array

@description('The name of the Key Vault secret.')
param keyVaultSecretName string

@description('The location of all resources.')
param location string

// Resource - App Service - Custom Domain
//////////////////////////////////////////////////
resource customDomain 'Microsoft.Web/sites/hostNameBindings@2022-03-01' = [for (appServiceTlsSetting, i) in appServiceTlsSettings: {
  name: '${appServiceTlsSetting.appServiceName}/${appServiceTlsSetting.applicationHostName}'
  properties: {
    hostNameType: appServiceTlsSetting.hostNameType
    sslState: appServiceTlsSetting.sslState
    customHostNameDnsRecordType: appServiceTlsSetting.customHostNameDnsRecordType
    siteName: appServiceTlsSetting.appServiceName
  }
}]

// Resource - App Service - Certificate
//////////////////////////////////////////////////
resource certificate 'Microsoft.Web/certificates@2022-03-01' = [for (appServiceTlsSetting, i) in appServiceTlsSettings: {
  name: appServiceTlsSetting.certificateName
  location: location
  properties: {
    keyVaultId: appServiceTlsSetting.keyVaultId
    keyVaultSecretName: keyVaultSecretName
    // password: certificatePassword
    serverFarmId: appServiceTlsSetting.serverFarmId
  }
}]

// Outputs
//////////////////////////////////////////////////
output certificateThumbprints array = [for (appServiceTlsSetting, i) in appServiceTlsSettings: {
  certificateThumbprint: certificate[i].properties.thumbprint
}]
