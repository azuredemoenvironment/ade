// Parameters
//////////////////////////////////////////////////
@description('The Azure Active Directory Tenant ID.')
param azureActiveDirectoryTenantID string

@description('The Azure Active Directory User ID.')
param azureActiveDirectoryUserID string

@description('The Service Principal Name ID of the Application Gateway Managed Identity.')
param applicationGatewayManagedIdentitySPNID string

@description('The Service Principal Name ID of the Container Registry Managed Identity.')
param containerRegistryManagedIdentitySPNID string

@description('The Password of the Container Registry Service Principal.')
param containerRegistrySPNPassword string

@description('The Application ID of the Container Registry Service Principal.')
param containerRegistrySPNAppID string

@description('The Object ID of the Container Registry Service Principal.')
param containerRegistrySPNObjectID string

@description('The Password of the GitHub Actions Service Principal.')
param githubActionsSPNPassword string

@description('The Application ID of the GitHub Actions Service Principal.')
param githubActionsSPNAppID string

@description('The Password of the REST API Service Principal.')
param restAPISPNPassword string

@description('The Application ID of the REST API Service Principal.')
param restAPISPNAppID string

@description('The name of the Key Vault.')
param keyVaultName string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

// Variables
//////////////////////////////////////////////////
var location = resourceGroup().location
var tags = {
  environment: 'production'
  function: 'key vault'
  costCenter: 'it'
}

// Resource - Key Vault
//////////////////////////////////////////////////
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enablePurgeProtection: true
    tenantId: azureActiveDirectoryTenantID
    publicNetworkAccess: 'enabled'
    accessPolicies: [
      {
        objectId: azureActiveDirectoryUserID
        tenantId: azureActiveDirectoryTenantID
        permissions: {
          keys: [
            'all'
          ]
          secrets: [
            'all'
          ]
          certificates: [
            'all'
          ]
        }
      }
      {
        objectId: applicationGatewayManagedIdentitySPNID
        tenantId: azureActiveDirectoryTenantID
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
      {
        objectId: containerRegistryManagedIdentitySPNID
        tenantId: azureActiveDirectoryTenantID
        permissions: {
          keys: [
            'get'
            'unwrapKey'
            'wrapKey'
          ]
        }
      }
      {
        objectId: 'abfa0a7c-a6b6-4736-8310-5855508787cd'
        tenantId: azureActiveDirectoryTenantID
        permissions: {
          secrets: [
            'get'
          ]
          certificates: [
            'get'
          ]
        }
      }
    ]
  }
}

// Resource - Key Vault - Diagnostic Settings
//////////////////////////////////////////////////
resource keyVaultDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: keyVault
  name: '${keyVault.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// Resource - Key Vault - Secret - containerregistryusername
//////////////////////////////////////////////////
resource containerRegistryUserNameSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  parent: keyVault
  name: 'containerRegistryUserName'
  properties: {
    value: containerRegistrySPNAppID
  }
}

// Resource - Key Vault - Secret - containerregistrypassword
//////////////////////////////////////////////////
resource containerRegistryPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  parent: keyVault
  name: 'containerRegistryPassword'
  properties: {
    value: containerRegistrySPNPassword
  }
}

// Resource - Key Vault - Secret - containerregistryobjectid
//////////////////////////////////////////////////
resource containerRegistryObjectIdSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  parent: keyVault
  name: 'containerRegistryObjectId'
  properties: {
    value: containerRegistrySPNObjectID
  }
}

// Resource - Key Vault - Secret - Githubactionsusername
//////////////////////////////////////////////////
resource githubActionsUserNameSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  parent: keyVault
  name: 'githubActionsUserName'
  properties: {
    value: githubActionsSPNAppID
  }
}

// Resource - Key Vault - Secret - githubActionsPassword
//////////////////////////////////////////////////
resource githubActionsPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  parent: keyVault
  name: 'githubActionsPassword'
  properties: {
    value: githubActionsSPNPassword
  }
}

// Resource - Key Vault - Secret - restAPIUserName
//////////////////////////////////////////////////
resource restAPIUserNameSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  parent: keyVault
  name: 'restAPIUserName'
  properties: {
    value: restAPISPNAppID
  }
}

// Resource - Key Vault - Secret - restAPIPassword
//////////////////////////////////////////////////
resource restAPIPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  parent: keyVault
  name: 'restAPIPassword'
  properties: {
    value: restAPISPNPassword
  }
}
