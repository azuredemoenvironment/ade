// Parameters
//////////////////////////////////////////////////
@description('The name of the Automation Account.')
param automationAccountName string

@description('The properties of the Automation Account')
param automationAccountProperties object

// @description('The sku of the Automation Account.')
// param automationAccountSku string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The ID of the Storage Account.')
param storageAccountId string

@description('The list of tags.')
param tags object

// Resource - Automation Account
//////////////////////////////////////////////////
resource automationAccount 'Microsoft.Automation/automationAccounts@2022-08-08' = {
  name: automationAccountName
  location:location
  tags: tags
  identity: {
    type: automationAccountProperties.identityType
  }      
  properties: {
    encryption: {
      keySource: automationAccountProperties.keySource
    }
    publicNetworkAccess: automationAccountProperties.publicNetworkAccess
    sku: {
      name: automationAccountProperties.sku
    }
  }
}

// Resource - Automation Account - Diagnostic Settings
//////////////////////////////////////////////////
resource automationAccountDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: automationAccount
  name: '${automationAccount.name}-diagnostics'
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
          enabled: true
          days: 7
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
    ]
  }
}

// Outputs
//////////////////////////////////////////////////
output automationAccountPrincipalId string = automationAccount.identity.principalId
