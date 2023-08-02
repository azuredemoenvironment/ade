// Parameters
//////////////////////////////////////////////////
@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The ID of the Firewall Subnet.')
param firewallManagementSubnetId string

@description('The properties of the Firewall Policy.')
param firewallPolicyProperties object

@description('The properties of the Firewall.')
param firewallProperties object

@description('The ID of the Firewall Subnet.')
param firewallSubnetId string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The array of Public IP Addresses.')
param publicIpAddresses array

@description('The ID of the Storage Account.')
param storageAccountId string

@description('The list of resource tags.')
param tags object

// Resource - Public Ip Address
//////////////////////////////////////////////////
resource pip 'Microsoft.Network/publicIPAddresses@2022-09-01' = [for (publicIpAddress, i) in publicIpAddresses: {
  name: publicIpAddress.name
  location: location
  tags: tags
  properties: {
    publicIPAllocationMethod: publicIpAddress.publicIPAllocationMethod
    publicIPAddressVersion: publicIpAddress.publicIPAddressVersion
  }
  sku: {
    name: publicIpAddress.sku
  }
}]

// Resource - Public Ip Address - Diagnostic Settings
//////////////////////////////////////////////////
resource publicIpAddressDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for (publicIpAddress, i) in publicIpAddresses: {
  scope: pip[i]
  name: '${publicIpAddress.name}-diagnostics'
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
}]

// Resource - Azure Firewall Policy
//////////////////////////////////////////////////
resource firewallPolicy 'Microsoft.Network/firewallPolicies@2022-01-01'= {
  name: firewallPolicyProperties.name
  location: location
  properties: {
    sku: {
      tier: firewallPolicyProperties.sku.tier
    }
    threatIntelMode: firewallPolicyProperties.threatIntelMode
  }
}

// Resource - Firewall
//////////////////////////////////////////////////
resource firewall 'Microsoft.Network/azureFirewalls@2022-09-01' = {
  name: firewallProperties.name
  location: location
  tags: tags
  properties: {
    sku: {
      name: firewallProperties.sku.name
      tier: firewallProperties.sku.tier
    }
    ipConfigurations: [
      {
        name: pip[0].name
        properties: {
          publicIPAddress: {
            id: pip[0].id
          }
          subnet: {
            id: firewallSubnetId
          }
        }
      }
    ]
    managementIpConfiguration: {
      name: pip[1].name
      properties: {
        subnet: {
          id: firewallManagementSubnetId
        }
        publicIPAddress: {
          id: pip[1].id
        }
      }
    }
    firewallPolicy: {
      id: firewallPolicy.id
    }
  }
}

// Resource - Firewall - Diagnostic Settings
//////////////////////////////////////////////////
resource firewallDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: firewall
  name: '${firewall.name}-diagnostics'
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
