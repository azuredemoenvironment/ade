// parameters
param location string
param logAnalyticsWorkspaceId string
param azureFirewallPublicIpAddressName string
param azureFirewallName string
param azureFirewallSubnetId string

// variables
var environmentName = 'production'
var functionName = 'networking'
var costCenterName = 'it'

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

// resource - public ip address - diagnostic settings - azure firewall
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

// resource - azure firewall
resource azureFirewall 'Microsoft.Network/azureFirewalls@2020-07-01' = {
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
