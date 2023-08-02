// Parameters
//////////////////////////////////////////////////
@description('The array of Key Vault Access Policies.')
param keyVaultAccessPolicies array

@description('The name of the Key Vault.')
param keyVaultName string

// Resource - Key Vault - Access Policies
//////////////////////////////////////////////////
resource accessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2023-02-01' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [for keyVaultAccessPolicy in keyVaultAccessPolicies: {
      objectId: keyVaultAccessPolicy.objectId
      tenantId: subscription().tenantId
      permissions: keyVaultAccessPolicy.permissions
    }]
  }
}
