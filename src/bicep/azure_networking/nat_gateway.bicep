// Parameters
//////////////////////////////////////////////////
@description('The location for all resources.')
param location string

@description('The name of the Nat Gateway.')
param natGatewayName string

@description('The name of the Nat Gateway Public IP Prefix.')
param natGatewayPublicIPPrefixName string

@description('The list of Resource tags')
param tags object

// Resource - Public Ip Prefix
//////////////////////////////////////////////////
resource natGatewaypublicIPPrefix 'Microsoft.Network/publicIPPrefixes@2020-07-01' = {
  name: natGatewayPublicIPPrefixName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    prefixLength: 31
    publicIPAddressVersion: 'IPv4'
  }
}

// Resource - Nat Gateway
//////////////////////////////////////////////////
resource natGateway 'Microsoft.Network/natGateways@2020-07-01' = {
  name: natGatewayName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    idleTimeoutInMinutes: 4
    publicIpPrefixes: [
      {
        id: natGatewaypublicIPPrefix.id
      }
    ]
  }
}

// Outputs
//////////////////////////////////////////////////
output natGatewayId string = natGateway.id
