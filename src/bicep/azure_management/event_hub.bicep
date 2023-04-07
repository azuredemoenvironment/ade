// Parameters
//////////////////////////////////////////////////
@description('The properties of the Event Hub Namespace.')
param eventHubNamespaceProperties object

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The list of resource tags.')
param tags object

// Resource - Event Hub Namespace
//////////////////////////////////////////////////
resource eventHubNamespace 'Microsoft.EventHub/namespaces@2022-10-01-preview' = {
  name: eventHubNamespaceProperties.eventHubNamespaceName
  location: location
  tags: tags
  sku: {
    name: eventHubNamespaceProperties.sku
    tier: eventHubNamespaceProperties.sku
    capacity: eventHubNamespaceProperties.skuCapacity
  }
  properties: {
    isAutoInflateEnabled: eventHubNamespaceProperties.autoInflate
  }
}

// Resource - Event Hub
//////////////////////////////////////////////////
resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2022-10-01-preview' = {
  parent: eventHubNamespace
  name: eventHubNamespaceProperties.eventHubName
  properties: {
    messageRetentionInDays: eventHubNamespaceProperties.messageRetention
    partitionCount: eventHubNamespaceProperties.partitions
  }
}

// Resource - Event Hub Authorization Rule
//////////////////////////////////////////////////
resource eventHubNamespaceAuthorizationRule 'Microsoft.EventHub/namespaces/authorizationRules@2022-10-01-preview' = {
  parent: eventHubNamespace
  name: eventHubNamespaceProperties.authorizationRuleName
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
resource eventHubNamespaceDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: eventHubNamespace
  name: '${eventHubNamespace.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        categoryGroup: 'allLogs'
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
