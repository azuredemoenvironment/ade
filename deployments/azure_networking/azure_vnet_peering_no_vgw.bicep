// parameters
param networkingResourceGroupName string
param virtualNetwork001Name string
param virtualNetwork002Name string
param virtualNetwork001Id string
param virtualNetwork002Id string

// resource - virtual network peering - virtual network 001 to virtual network 002
resource vnetPeering001to002 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-08-01' = {
  name: '${virtualNetwork001Name}/${virtualNetwork001Name}-${virtualNetwork002Name}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: virtualNetwork002Id
    }
  }
}

// resource - virtual network peering - virtual network 002 to virtual network 001
resource vnetPeering002to001 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-08-01' = {
  name: '${virtualNetwork002Name}/${virtualNetwork002Name}-${virtualNetwork001Name}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: virtualNetwork001Id
    }
  }
}
