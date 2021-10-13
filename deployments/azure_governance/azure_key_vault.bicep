// Parameters
//////////////////////////////////////////////////
@description('The Azure Active Directory User ID.')
param azureActiveDirectoryUserID string

@description('The Service Principal Name ID of the Application Gateway Managed Identity.')
param applicationGatewayManagedIdentityPrincipalID string

@description('The Service Principal Name ID of the Container Registry Managed Identity.')
param containerRegistryManagedIdentityPrincipalID string

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
    tenantId: subscription().tenantId
    publicNetworkAccess: 'enabled'
    accessPolicies: [
      {
        objectId: azureActiveDirectoryUserID
        tenantId: subscription().tenantId
        permissions: {
          keys: [
            'all'
            'purge'
          ]
          secrets: [
            'all'
            'purge'
          ]
          certificates: [
            'all'
            'purge'
          ]
        }
      }
      {
        objectId: applicationGatewayManagedIdentityPrincipalID
        tenantId: subscription().tenantId
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
      {
        objectId: containerRegistryManagedIdentityPrincipalID
        tenantId: subscription().tenantId
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
        tenantId: subscription().tenantId
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
