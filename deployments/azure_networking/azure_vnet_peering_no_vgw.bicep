// parameters
param networkingResourceGroupName string
param virtualNetwork001Name string
param virtualNetwork002Name string

// existing resources
// virtual network 001
resource virtualNetwork001 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: virtualNetwork001Name
}
// virtual network 002
resource virtualNetwork002 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: virtualNetwork002Name
}

// resource - virtual network peering - virtual network 001 to virtual network 002
resource vnetPeering001to002 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-08-01' = {
  name: '${virtualNetwork001.name}/${virtualNetwork001.name}-${virtualNetwork002.name}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: virtualNetwork002.id
    }
  }
}

// resource - virtual network peering - virtual network 002 to virtual network 001
resource vnetPeering002to001 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-08-01' = {
  name: '${virtualNetwork002.name}/${virtualNetwork002.name}-${virtualNetwork001.name}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: virtualNetwork001.id
    }
  }
}
