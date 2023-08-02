// Parameters
//////////////////////////////////////////////////
@description('The properties of the Event Hub Namespace Authorization Rule.')
param eventHubNameSpaceAuthorizationRuleProperties object

@description('The properties of the Event Hub Namespace.')
param eventHubNamespaceProperties object

@description('The properties of the Event Hub.')
param eventHubProperties object

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The list of resource tags.')
param tags object

// Resource - Event Hub Namespace
//////////////////////////////////////////////////
resource eventHubNamespace 'Microsoft.EventHub/namespaces@2022-10-01-preview' = {
  name: eventHubNamespaceProperties.name
  location: location
  tags: tags
  sku: {
    name: eventHubNamespaceProperties.sku.name
    tier: eventHubNamespaceProperties.sku.tier
    capacity: eventHubNamespaceProperties.sku.capacity
  }
  properties: {
    isAutoInflateEnabled: eventHubNamespaceProperties.properties.isAutoInflateEnabled
  }
}

// Resource - Event Hub
//////////////////////////////////////////////////
resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2022-10-01-preview' = {
  parent: eventHubNamespace
  name: eventHubProperties.name
  properties: {
    messageRetentionInDays: eventHubProperties.properties.messageRetentionInDays
    partitionCount: eventHubProperties.properties.partitionCount
  }
}

// Resource - Event Hub Authorization Rule
//////////////////////////////////////////////////
resource eventHubNamespaceAuthorizationRule 'Microsoft.EventHub/namespaces/authorizationRules@2022-10-01-preview' = {
  parent: eventHubNamespace
  name: eventHubNameSpaceAuthorizationRuleProperties.name
  properties: {
    rights: eventHubNameSpaceAuthorizationRuleProperties.properties.rights
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
