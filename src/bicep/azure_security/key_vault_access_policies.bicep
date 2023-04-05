// Parameters
//////////////////////////////////////////////////
@description('The Principal Id of the Application Gateway Managed Identity.')
param applicationGatewayManagedIdentityPrincipalId string

@description('The secrets permissions of the Principal Id of the Application Gateway Managed Identity.')
param applicationGatewayManagedIdentityPrincipalIdSecretsPermissions array

@description('The Principal Id of the Container Registry Managed Identity.')
param containerRegistryManagedIdentityPrincipalId string

@description('The certificates permissions of the Principal Id of the Container Registry Managed Identity.')
param containerRegistryManagedIdentityPrincipalIdCertificatesPermissions array

@description('The keys permissions of the Principal Id of the Container Registry Managed Identity.')
param containerRegistryManagedIdentityPrincipalIdKeysPermissions array

@description('The secrets permissions of the Principal Id of the Container Registry Managed Identity.')
param containerRegistryManagedIdentityPrincipalIdSecretsPermissions array

@description('The name of the Key Vault.')
param keyVaultName string

// Resource - Key Vault - Access Policies
//////////////////////////////////////////////////
resource keyVaultAccessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2022-11-01' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        objectId: applicationGatewayManagedIdentityPrincipalId
        tenantId: subscription().tenantId
        permissions: {
          secrets: applicationGatewayManagedIdentityPrincipalIdSecretsPermissions
        }
      }
      {
        objectId: containerRegistryManagedIdentityPrincipalId
        tenantId: subscription().tenantId
        permissions: {
          certificates: containerRegistryManagedIdentityPrincipalIdCertificatesPermissions
          keys: containerRegistryManagedIdentityPrincipalIdKeysPermissions
          secrets: containerRegistryManagedIdentityPrincipalIdSecretsPermissions
        }
      }
    ]
  }
}
