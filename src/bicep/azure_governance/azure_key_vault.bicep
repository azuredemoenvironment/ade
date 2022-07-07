// Parameters
//////////////////////////////////////////////////
@description('The Service Principal Name ID of the Application Gateway Managed Identity.')
param applicationGatewayManagedIdentityPrincipalID string

@description('The Base64 encoded certificate for Azure resources.')
param certificateBase64String string

@description('The Service Principal Name ID of the Container Registry Managed Identity.')
param containerRegistryManagedIdentityPrincipalID string

@description('The ID of the Diagnostics Storage Account.')
param diagnosticsStorageAccountId string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The name of the Key Vault.')
param keyVaultName string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The password for Azure resources.')
param resourcePassword string

// Variables
//////////////////////////////////////////////////
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
          certificates: [
            'get'
          ]
          keys: [
            'get'
            'unwrapKey'
            'wrapKey'
          ]
          secrets: [
            'get'
          ]
        }
      }
    ]
  }
}

// Resource - Key Vault - Secret - Certificate
//////////////////////////////////////////////////
resource certificateBase64StringSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'certificate'
  properties: {
    value: certificateBase64String
  }
}

// Resource - Key Vault - Secret - Resource Password
//////////////////////////////////////////////////
resource resourcePasswordSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'resourcePassword'
  properties: {
    value: resourcePassword
  }
}

// Resource - Key Vault - Diagnostic Settings
//////////////////////////////////////////////////
resource keyVaultDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: keyVault
  name: '${keyVault.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}
