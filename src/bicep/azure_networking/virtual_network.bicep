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

@description('The list of Resource tags')
param tags object

@description('The array of properties for the Virtual Networks.')
param virtualNetworks array

// Resource - Virtual Network
//////////////////////////////////////////////////
@batchSize(1)
resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' = [for virtualNetwork in virtualNetworks: {
  name: virtualNetwork.name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetwork.addressPrefix
      ]
    }
    subnets: [for subnet in virtualNetwork.subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.subnetPrefix
        natGateway: {
          id: subnet.natGatewayId
        }
        networkSecurityGroup: {
          id: subnet.networkSecurityGroupId
        }
        privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
        serviceEndpoints: [
          {
            service: subnet.serviceEndpoint
          }
        ]
      }
    }]
  }
  resource subnet 'subnets' existing = [for (subnet, i) in virtualNetwork.subnets: {
    name: subnet[i].name
  }]
}

// Resource - Virtual Network - Diagnostic Settings
//////////////////////////////////////////////////
@batchSize(1)
resource virtualNetworkDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = [for (virtualNetwork, i) in virtualNetworks: {
  scope: vnet[i]
  name: '${virtualNetwork.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'VMProtectionAlerts'
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
}]

// Outputs
//////////////////////////////////////////////////
output azureBastionSubnetId string = virtualNetwork001::azureBastionSubnet.id
output azureFirewallSubnetId string = virtualNetwork001::azureFirewallSubnet.id
output gatewaySubnetId string = virtualNetwork001::gatewaySubnet.id
output virtualNetwork001Id string = virtualNetwork001.id

output vnets array = [for (virtualNetwork, i) in virtualNetworks: {
  virtualNetworkId: vnet[i].id

}]
