// Parameters
//////////////////////////////////////////////////
@description('The name of the VPN Connection.')
param connectionName string

@description('The value for the VPN Connection Shared Key.')
@secure()
param connectionSharedKey string

@description('The ID of the Gateway Subnet.')
param gatewaySubnetId string

@description('The address prefix of the on-premises network.')
param localNetworkGatewayAddressPrefix string

@description('The name of the Local Network Gateway')
param localNetworkGatewayName string

@description('The region location of deployment.')
param location string = resourceGroup().location

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The public IP address of the on-premises network.')
param sourceAddressPrefix string

@description('The name of the VPN Gateway.')
param vpnGatewayName string

@description('The name of the VPN Gateway Public IP Address.')
param vpnGatewayPublicIpAddressName string

// Variables
//////////////////////////////////////////////////
var tags = {
  environment: 'production'
  function: 'networking'
  costCenter: 'it'
}

// Resource - Public Ip Address
//////////////////////////////////////////////////
resource vpnGatewayPublicIpAddress 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: vpnGatewayPublicIpAddressName
  location: location
  tags: tags
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

// Resource - Public Ip Address - Diagnostic Settings
//////////////////////////////////////////////////
resource vpnGatewayPublicIpAddressDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: vpnGatewayPublicIpAddress
  name: '${vpnGatewayPublicIpAddress.name}-diagnostics'
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

// Resource - Local Network Gateway
//////////////////////////////////////////////////
resource localNetworkGateway 'Microsoft.Network/localNetworkGateways@2020-08-01' = {
  name: localNetworkGatewayName
  location: location
  tags: tags
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: [
        localNetworkGatewayAddressPrefix
      ]
    }
    gatewayIpAddress: sourceAddressPrefix
  }
}

// Resource - Vpn Gateway
//////////////////////////////////////////////////
resource vpnGateway 'Microsoft.Network/virtualNetworkGateways@2020-08-01' = {
  name: vpnGatewayName
  location: location
  tags: tags
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

// Resource - Vpn Gateway - Diagnostic Settings
//////////////////////////////////////////////////
resource vpnGatewayDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${vpnGateway.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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

// Resource - Connection
//////////////////////////////////////////////////
resource connection 'Microsoft.Network/connections@2020-08-01' = {
  name: connectionName
  location: location
  tags: tags
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
