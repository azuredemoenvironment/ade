// Parameters
//////////////////////////////////////////////////
@description('The ID of the hub Virtual Network.')
param hubVirtualNetworkId string

@description('The name of the hub Virtual Network.')
param hubVirtualNetworkName string

@description('The properties of the Virtual Network Peering.')
param peeringProperties object

@description('The ID of the spoke Virtual Network.')
param spokeVirtualNetworkId string

@description('The name of the spoke Virtual Network.')
param spokeVirtualNetworkName string

// Resource - Virtual Network Peering - Hub to Spoke
//////////////////////////////////////////////////
resource vnetPeeringHubToSpoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-01-01' = {
  name: '${hubVirtualNetworkName}/${hubVirtualNetworkName}-${spokeVirtualNetworkName}'
  properties: {
    allowVirtualNetworkAccess: peeringProperties.allowVirtualNetworkAccess
    allowForwardedTraffic: peeringProperties.allowForwardedTraffic
    allowGatewayTransit: peeringProperties.allowGatewayTransit
    useRemoteGateways: peeringProperties.useRemoteGateways
    remoteVirtualNetwork: {
      id: spokeVirtualNetworkId
    }
  }
}

// Resource - Virtual Network Peering - Spoke to Hub
//////////////////////////////////////////////////
resource vnetPeeringSpokeToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-01-01' = {
  name: '${spokeVirtualNetworkName}/${spokeVirtualNetworkName}-${hubVirtualNetworkName}'
  properties: {
    allowVirtualNetworkAccess: peeringProperties.allowVirtualNetworkAccess
    allowForwardedTraffic: peeringProperties.allowForwardedTraffic
    allowGatewayTransit: peeringProperties.allowGatewayTransit
    useRemoteGateways: peeringProperties.useRemoteGateways
    remoteVirtualNetwork: {
      id: hubVirtualNetworkId
    }
  }
}
