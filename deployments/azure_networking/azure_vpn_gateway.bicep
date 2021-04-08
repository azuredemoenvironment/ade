// parameters
param location string
param sourceAddressPrefix string
param localNetworkGatewayAddressPrefix string
param connectionSharedKey string
param monitorResourceGroupName string
param logAnalyticsWorkspaceName string
param networkingResourceGroupName string
param virtualNetwork001Name string
param vpnGatewayPublicIpAddressName string
param localNetworkGatewayName string
param vpnGatewayName string
param connectionName string
param gatewaySubnetId string

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
resource virtualNetwork001 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: virtualNetwork001Name
}

// resource - public ip address - vpn gateway
resource vpnGatewayPublicIpAddress 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: vpnGatewayPublicIpAddressName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

// resource - public ip address - vpn gateway - diagnostic settings
resource azureFirewallPublicIpAddressDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${vpnGatewayPublicIpAddress.name}-diagnostics'
  scope: vpnGatewayPublicIpAddress
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

// resource - local network gateway
resource localNetworkGateway 'Microsoft.Network/localNetworkGateways@2020-08-01' = {
  name: localNetworkGatewayName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: [
        localNetworkGatewayAddressPrefix
      ]
    }
    gatewayIpAddress: sourceAddressPrefix
  }
}

// resource - vpn gateway
resource vpnGateway 'Microsoft.Network/virtualNetworkGateways@2020-08-01' = {
  name: vpnGatewayName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    gatewayType: 'Vpn'
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: gatewaySubnetId
          }
          publicIPAddress: {
            id: vpnGatewayPublicIpAddress.id
          }
        }
      }
    ]
    vpnType: 'RouteBased'
    sku: {
      name: 'Basic'
      tier: 'Basic'
    }
  }
}

// resource - vpn gateway - diagnostic settings
resource vpnGatewayDiagnostics 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${vpnGateway.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'GatewayDiagnosticLog'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'TunnelDiagnosticLog'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'RouteDiagnosticLog'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'IKEDiagnosticLog'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'P2SDiagnosticLog'
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

// resource - connection
resource connection 'Microsoft.Network/connections@2020-08-01' = {
  name: connectionName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    virtualNetworkGateway1: {
      id: vpnGateway.id
      properties: {}
    }
    localNetworkGateway2: {
      id: localNetworkGateway.id
      properties: {}
    }
    connectionType: 'IPsec'
    routingWeight: 10
    sharedKey: connectionSharedKey
  }
}
