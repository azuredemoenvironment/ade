// Parameters
//////////////////////////////////////////////////
@description('The base64 encoded certificate for Azure resources.')
param certificateBase64String string

@description('The ID of the Storage Account.')
param storageAccountId string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

// @description('The name of the Key Vault.')
// param keyVaultName string

param keyVaultProperties object

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The password for Azure resources.')
@secure()
param resourcePassword string

@description('The list of Resource tags')
param tags object

// Resource - Key Vault
//////////////////////////////////////////////////
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: keyVaultProperties.name
  location: location
  tags: tags
  properties: {
    sku: {
      name: keyVaultProperties.skuName
      family: keyVaultProperties.family
    }
    enabledForDeployment: keyVaultProperties.enabledForDeployment
    enabledForDiskEncryption: keyVaultProperties.enabledForDiskEncryption
    enabledForTemplateDeployment: keyVaultProperties.enabledForTemplateDeployment
    enableSoftDelete: keyVaultProperties.enableSoftDelete
    softDeleteRetentionInDays: keyVaultProperties.softDeleteRetentionInDays
    enablePurgeProtection: keyVaultProperties.enablePurgeProtection
    tenantId: subscription().tenantId
    publicNetworkAccess: keyVaultProperties.publicNetworkAccess
  }
}

// Resource - Key Vault
//////////////////////////////////////////////////
// resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
//   name: keyVaultName
//   location: location
//   tags: tags
//   properties: {
//     sku: {
//       name: 'standard'
//       family: 'A'
//     }
//     enabledForDeployment: true
//     enabledForDiskEncryption: true
//     enabledForTemplateDeployment: true
//     enableSoftDelete: true
//     softDeleteRetentionInDays: 7
//     enablePurgeProtection: true
//     tenantId: subscription().tenantId
//     publicNetworkAccess: 'enabled'
//   }
// }

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
    storageAccountId: storageAccountId
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
