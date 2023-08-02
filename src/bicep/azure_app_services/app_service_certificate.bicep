// Parameters
//////////////////////////////////////////////////
@description('The name of the certificate.')
param certificateName string

@description('The Id of the Key Vault.')
param keyVaultId string

@description('The name of the Key Vault secret.')
param keyVaultSecretName string

@description('The location of all resources.')
param location string

@description('The Id of the App Service Plan.')
param serverFarmId string

// Resource - App Service - Certificate
//////////////////////////////////////////////////
resource certificate 'Microsoft.Web/certificates@2022-03-01' = {
  name: certificateName
  location: location
  properties: {
    keyVaultId: keyVaultId
    keyVaultSecretName: keyVaultSecretName
    serverFarmId: serverFarmId
  }
}

// Outputs
//////////////////////////////////////////////////
output certificateThumbprint string =  certificate.properties.thumbprint
