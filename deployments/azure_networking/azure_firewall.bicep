// Parameters
//////////////////////////////////////////////////
@description('The name of the Azure Firewall')
param azureFirewallName string

@description('The name of the Azure Firewall Public IP Address.')
param azureFirewallPublicIpAddressName string

@description('The ID of the Azure Firewall Subnet.')
param azureFirewallSubnetId string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

// Variables
//////////////////////////////////////////////////
var location = resourceGroup().location
var tags = {
  environment: 'production'
  function: 'networking'
  costCenter: 'it'
}

// Resource - Public Ip Address
//////////////////////////////////////////////////
resource azureFirewallPublicIpAddress 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: azureFirewallPublicIpAddressName
  location: location
  tags: tags
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

// Resource - Public Ip Address - Diagnostic Settings
//////////////////////////////////////////////////
resource azureFirewallPublicIpAddressDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: azureFirewallPublicIpAddress
  name: '${azureFirewallPublicIpAddress.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'DDoSProtectionNotifications'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'DDoSMitigationFlowLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'DDoSMitigationReports'
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

// Resource - Azure Firewall
//////////////////////////////////////////////////
resource azureFirewall 'Microsoft.Network/azureFirewalls@2020-07-01' = {
  name: azureFirewallName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          publicIPAddress: {
            id: azureFirewallPublicIpAddress.id
          }
          subnet: {
            id: azureFirewallSubnetId
          }
        }
      }
    ]
    applicationRuleCollections: [
      {
        name: 'InternetOutbound'
        properties: {
          priority: 100
          action: {
            type: 'Allow'
          }
          rules: [
            {
              name: 'Microsoft'
              protocols: [
                {
                  port: 80
                  protocolType: 'Http'
                }
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
              targetFqdns: [
                '*.microsoft.com'
                'microsoft.com'
              ]
            }
            {
              name: 'GitHub'
              protocols: [
                {
                  port: 80
                  protocolType: 'Http'
                }
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
              targetFqdns: [
                '*.github.com'
                'github.com'
                'githubassets.com'
              ]
            }
          ]
        }
      }
    ]
  }
}

// Resource - Azure Firewall - Diagnostic Settings
//////////////////////////////////////////////////
resource azureFirewallDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: azureFirewall
  name: '${azureFirewall.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'AzureFirewallApplicationRule'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AzureFirewallNetworkRule'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AzureFirewallDnsProxy'
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
