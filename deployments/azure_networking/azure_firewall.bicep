// parameters
param location string
param monitorResourceGroupName string
param logAnalyticsWorkspaceName string
param networkingResourceGroupName string
param virtualNetwork001Name string
param azureFirewallPublicIpAddressName string
param azureFirewallName string
param azureFirewallSubnetId string

// variables
var environmentName = 'production'
var functionName = 'networking'
var costCenterName = 'it'

// existing resources
// log analytics
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(monitorResourceGroupName)
}
// virtual network
var azureFirewallSubnetName = 'AzureFirewallSubnet'
resource virtualNetwork001 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: virtualNetwork001Name
}

// resource - public ip address - azure firewall
resource azureFirewallPublicIpAddress 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: azureFirewallPublicIpAddressName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

// resource - public ip address - azure firewall - diagnostic settings
resource azureFirewallPublicIpAddressDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${azureFirewallPublicIpAddress.name}-diagnostics'
  scope: azureFirewallPublicIpAddress
  properties: {
    workspaceId: logAnalyticsWorkspace.id
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

resource azureFirewall 'Microsoft.Network/azureFirewalls@2020-08-01' = {
  name: azureFirewallName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
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

// resource - azure firewall - diagnostic settings
resource azureFirewallDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${azureFirewall.name}-diagnostics'
  scope: azureFirewall
  properties: {
    workspaceId: logAnalyticsWorkspace.id
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
