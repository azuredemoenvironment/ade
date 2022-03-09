// Parameters
//////////////////////////////////////////////////
@description('The name of the Event Hub.')
param eventHubName string

@description('The name of the Event Hub Namespace.')
param eventHubNamespaceName string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

// Variables
//////////////////////////////////////////////////
var location = resourceGroup().location
var tags = {
  environment: 'production'
  function: 'monitoring and diagnostics'
  costCenter: 'it'
}

// Resource - Event Hub Namespace
//////////////////////////////////////////////////
resource eventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: eventHubNamespaceName
  location: location
  tags: tags
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 1
  }
  properties: {
    isAutoInflateEnabled: false
    zoneRedundant: true
    maximumThroughputUnits: 0
  }
}

// Resource - Event Hub
//////////////////////////////////////////////////
resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2017-04-01' = {
  name: '${eventHubNamespace.name}/${eventHubName}'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 1
  }
}

// Resource - Event Hub Authorization Rule
//////////////////////////////////////////////////
resource eventHubNamespaceAuthorizationRule 'Microsoft.EventHub/namespaces/authorizationRules@2021-11-01' = {
  name: '${eventHubNamespace.name}/RootManageSharedAccessKey'
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

// Resource - Event Hub Namespace - Diagnostic Settings
//////////////////////////////////////////////////
resource eventHubNamespaceDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: eventHubNamespace
  name: '${eventHubNamespace.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'ArchiveLogs'
        enabled: true
      }
      {
        category: 'OperationalLogs'
        enabled: true
      }
      {
        category: 'AutoScaleLogs'
        enabled: true
      }
      {
        category: 'KafkaCoordinatorLogs'
        enabled: true
      }
      {
        category: 'KafkaUserErrorLogs'
        enabled: true
      }
      {
        category: 'EventHubVNetConnectionEvent'
        enabled: true
      }
      {
        category: 'CustomerManagedKeyUserLogs'
        enabled: true
      }
      {
        category: 'RuntimeAuditLogs'
        enabled: true
      }
      {
        category: 'ApplicationMetricsLogs'
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

// Outputs
//////////////////////////////////////////////////
output eventHubNamespaceAuthorizationRuleId string = eventHubNamespaceAuthorizationRule.id
