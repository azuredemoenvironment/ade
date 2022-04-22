// Parameters
//////////////////////////////////////////////////
@description('The ID of Virtual Network 001.')
param virtualNetwork001Id string

@description('The name of Virtual Network 001.')
param virtualNetwork001Name string

@description('The ID of Virtual Network 002.')
param virtualNetwork002Id string

@description('The name of Virtual Network 002.')
param virtualNetwork002Name string

// Resource - Virtual Network Peering - Virtual Network 001 To Virtual Network 002
//////////////////////////////////////////////////
resource vnetPeering001to002 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-08-01' = {
  name: '${virtualNetwork001Name}/${virtualNetwork001Name}-${virtualNetwork002Name}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: true
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: virtualNetwork002Id
    }
  }
}

// Resource - Virtual Network Peering - Virtual Network 002 To Virtual Network 001
//////////////////////////////////////////////////
resource vnetPeering002to001 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-08-01' = {
  name: '${virtualNetwork002Name}/${virtualNetwork002Name}-${virtualNetwork001Name}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: true
    remoteVirtualNetwork: {
      id: virtualNetwork001Id
    }
  }
}
