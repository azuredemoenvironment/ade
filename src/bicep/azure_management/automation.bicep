// Parameters
//////////////////////////////////////////////////
@description('The array of Automation Runbooks.')
param automationRunbooks array

@description('The properties of the Automation Account')
param automationAccountProperties object

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The ID of the Storage Account.')
param storageAccountId string

@description('The list of resource tags.')
param tags object

// Resource - Automation Account
//////////////////////////////////////////////////
resource automationAccount 'Microsoft.Automation/automationAccounts@2022-08-08' = {
  name: automationAccountProperties.name
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

// Resource - Automation Runbook
//////////////////////////////////////////////////
resource runbook 'Microsoft.Automation/automationAccounts/runbooks@2022-08-08' = [for (automationRunbook, i) in automationRunbooks: {
  parent: automationAccount
  name: automationRunbook.runbookName
  location: location
  properties: {
    runbookType: automationRunbook.runbookType
    logVerbose: automationRunbook.logVerbose
    logProgress: automationRunbook.logProgress
    publishContentLink: {
      uri: automationRunbook.uri
    }
  }
}]

// Resource - Automation Schedule
//////////////////////////////////////////////////
resource schedule 'Microsoft.Automation/automationAccounts/schedules@2022-08-08' = [for (automationRunbook, i) in automationRunbooks: {
  parent: automationAccount
  name: automationRunbook.scheduleName 
  properties: {
    frequency: automationRunbook.frequency
    interval: automationRunbook.interval
    startTime: automationRunbook.startTime
    timeZone: automationRunbook.timeZone
  }
}]

// Resource - Automation Job Schedule - App Service Scale Down
//////////////////////////////////////////////////
resource jobSchedule 'Microsoft.Automation/automationAccounts/jobSchedules@2022-08-08' = [for (automationRunbook, i) in automationRunbooks: {
  parent: automationAccount
  name: automationRunbook.jobScheduleName
  properties: {
    runbook: {
      name: runbook[i].name
    }
    schedule: {
      name: schedule[i].name
    }
  }
}]

// Outputs
//////////////////////////////////////////////////
output automationAccountPrincipalId string = automationAccount.identity.principalId
