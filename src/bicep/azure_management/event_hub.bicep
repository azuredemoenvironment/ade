// Parameters
//////////////////////////////////////////////////
@description('The name of the Event Hub.')
param eventHubName string

@description('The autoinflate setting of the Event Hub Namespace.')
param eventHubNamespaceAutoInflate bool

@description('The name of the Event Hub Namespace.')
param eventHubNamespaceName string

@description('The sku of the Event Hub Namespace.')
param eventHubNamespaceSku string

@description('The sku capacity of the Event Hub Namespace.')
param eventHubNamespaceSkuCapacity int

@description('The value in days for Event Hub message retention.')
param eventHubMessageRetention int

@description('The number of Event Hub partitions.')
param eventHubPartitions int

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The list of Resource tags')
param tags object

// Resource - Event Hub Namespace
//////////////////////////////////////////////////
resource eventHubNamespace 'Microsoft.EventHub/namespaces@2022-10-01-preview' = {
  name: eventHubNamespaceName
  location: location
  tags: tags
  sku: {
    name: eventHubNamespaceSku
    tier: eventHubNamespaceSku
    capacity: eventHubNamespaceSkuCapacity
  }
  properties: {
    isAutoInflateEnabled: eventHubNamespaceAutoInflate
  }
}

// Resource - Event Hub
//////////////////////////////////////////////////
resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2022-10-01-preview' = {
  name: '${eventHubNamespace.name}/${eventHubName}'
  properties: {
    messageRetentionInDays: eventHubMessageRetention
    partitionCount: eventHubPartitions
  }
}

// Resource - Event Hub Authorization Rule
//////////////////////////////////////////////////
resource eventHubNamespaceAuthorizationRule 'Microsoft.EventHub/namespaces/authorizationRules@2022-10-01-preview' = {
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
output eventHubNamespaceAuthorizationRuleId string = eventHubNamespaceAuthorizationRule.id
