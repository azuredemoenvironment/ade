// Parameters
//////////////////////////////////////////////////
@description('The base64 encoded certificate for Azure resources.')
param certificateBase64String string

@description('The certificate secret name.')
param certificateSecretName string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The name of the Key Vault.')
param keyVaultName string

@description('The properties of the Key Vault.')
param keyVaultProperties object

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The password for Azure resources.')
@secure()
param resourcePassword string

@description('The resource password secret name.')
param resourcePasswordSecretName string

@description('The ID of the Storage Account.')
param storageAccountId string

@description('The list of resource tags')
param tags object

// Resource - Key Vault
//////////////////////////////////////////////////
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
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
    accessPolicies: []
  }
}

// Resource - Key Vault - Secret - Certificate
//////////////////////////////////////////////////
resource certificateBase64StringSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: certificateSecretName
  properties: {
    value: certificateBase64String
  }
}

// Resource - Key Vault - Secret - Resource Password
//////////////////////////////////////////////////
resource resourcePasswordSecret 'Microsoft.KeyVault/vaults/secrets@2022-11-01' = {
  parent: keyVault
  name: resourcePasswordSecretName
  properties: {
    value: resourcePassword
  }
}

// Resource - Key Vault - Diagnostic Settings
//////////////////////////////////////////////////
resource keyVaultDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: keyVault
  name: '${keyVault.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: storageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        categoryGroup: 'allLogs'
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

// Outputs
//////////////////////////////////////////////////
output keyVaultName string = keyVault.name
