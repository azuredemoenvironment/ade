// parameters
param location string = resourceGroup().location
param keyVaultName string
param azureActiveDirectoryTenantID string
param azureActiveDirectoryUserID string
param applicationGatewayManagedIdentitySPNID string
param containerRegistryManagedIdentitySPNID string
param containerRegistrySPNPassword string
param containerRegistrySPNAppID string
param containerRegistryObjectId string
param githubActionsSPNPassword string
param githubActionsSPNAppID string
param githubActionsObjectId string
param restAPISPNPassword string
param restAPISPNAppID string
param restAPIObjectId string

//variables
var environmentName = 'production'
var functionName = 'key vault'
var costCenterName = 'it'

// existing resources
// log analytics
param logAnalyticsWorkspaceResourceGroupName string
param logAnalyticsWorkspaceName string
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(logAnalyticsWorkspaceResourceGroupName)
}

// resource - key vault
resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
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
          secrets: [
            'all'
          ]
          certificates: [
            'all'
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
output keyVaultResourceID string = keyVault.id

// resource - key vault - diagnostic settings
resource keyVaultDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${keyVault.name}-diagnostics'
  scope: keyVault
  properties: {
    workspaceId: logAnalyticsWorkspace.id
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

// resource - key vault - encryption key
resource keyVaultKey 'Microsoft.KeyVault/vaults/keys@2019-09-01' = {
  name: '${keyVault.name}/${'encryptionKey'}'
  properties: {
    kty: 'RSA'
    keyOps: [
      'encrypt'
      'decrypt'
    ]
    keySize: 4096
  }
}

// resource - key vault - secret - containerRegistryUserName
resource containerRegistryUserNameSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVault.name}/${'containerRegistryUserName'}'
  properties: {
    value: containerRegistrySPNAppID
  }
}

// resource - key vault - secret - containerRegistryPassword
resource containerRegistryPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVault.name}/${'containerRegistryPassword'}'
  properties: {
    value: containerRegistrySPNPassword
  }
}

// resource - key vault - secret - containerRegistryObjectId
resource containerRegistryObjectIdSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVault.name}/${'containerRegistryObjectId'}'
  properties: {
    value: containerRegistryObjectId
  }
}

// resource - key vault - secret - githubActionsUserName
resource githubActionsUserNameSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVault.name}/${'githubActionsUserName'}'
  properties: {
    value: githubActionsSPNAppID
  }
}

// resource - key vault - secret - githubActionsPassword
resource githubActionsPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVault.name}/${'githubActionsPassword'}'
  properties: {
    value: githubActionsSPNPassword
  }
}

// resource - key vault - secret - githubActionsObjectId
resource githubActionsObjectIdSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVault.name}/${'githubActionsObjectId'}'
  properties: {
    value: githubActionsObjectId
  }
}

// resource - key vault - secret - restAPIUserName
resource restAPIUserNameSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVault.name}/${'restAPIUserName'}'
  properties: {
    value: restAPISPNAppID
  }
}

// resource - key vault - secret - restAPIPassword
resource restAPIPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVault.name}/${'restAPIPassword'}'
  properties: {
    value: restAPISPNPassword
  }
}

// resource - key vault - secret - restAPIObjectId
resource restAPIObjectIdSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVault.name}/${'restAPIObjectId'}'
  properties: {
    value: restAPIObjectId
  }
}