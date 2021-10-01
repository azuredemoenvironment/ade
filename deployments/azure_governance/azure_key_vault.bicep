// Parameters
//////////////////////////////////////////////////
@description('The Azure Active Directory Tenant ID.')
param azureActiveDirectoryTenantID string

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

@description('The Service Principal property objects in an array.')
param servicePrincipals array

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
        objectId: applicationGatewayManagedIdentityPrincipalID
        tenantId: azureActiveDirectoryTenantID
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
      {
        objectId: containerRegistryManagedIdentityPrincipalID
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

// Resource - Key Vault - Secret - Service Principal Password
resource servicePrincipalPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = [for servicePrincipal in servicePrincipals: {
  parent: keyVault
  name: '${servicePrincipal.name}SpnPassword'
  properties: {
    value: servicePrincipal.password
  }
}]

// Resource - Key Vault - Secret - ApplicationId
resource servicePrincipalAppIdSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = [for servicePrincipal in servicePrincipals: {
  parent: keyVault
  name: '${servicePrincipal.name}AppId'
  properties: {
    value: servicePrincipal.appId
  }
}]

// Resource - Key Vault - Secret - Service Principal Object Id
resource servicePrincipalObjectIdSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = [for servicePrincipal in servicePrincipals: {
  parent: keyVault
  name: '${servicePrincipal.name}objectId'
  properties: {
    value: servicePrincipal.objectId
  }
}]
