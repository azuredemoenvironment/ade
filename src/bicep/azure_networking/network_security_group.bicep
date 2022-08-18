// Parameters
//////////////////////////////////////////////////
@description('The ID of the Diagnostics Storage Account.')
param diagnosticsStorageAccountId string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The array of Network Security Group names and properties.')
param networkSecurityGroups array

@description('The list of Resource tags')
param tags object

// Resource - Network Security Group
//////////////////////////////////////////////////
resource nsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = [for (networkSecurityGroup, i) in networkSecurityGroups: {
  name: networkSecurityGroup.name
  location: location
  tags: tags
  properties: networkSecurityGroup.properties
}]

// Resource - Network Security Group - Diagnostic Settings
//////////////////////////////////////////////////
resource nsgDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = [for (networkSecurityGroup, i) in networkSecurityGroups: {
  scope: nsg[i]
  name: '${networkSecurityGroup.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
      }
    ]
  }
}]


// Outputs
//////////////////////////////////////////////////
output networkSecurityGroupProperties array = [for (networkSecurityGroup, i) in networkSecurityGroups: {
  name: nsg[i].name
  resourceId: nsg[i].id
}]
