// Parameters
//////////////////////////////////////////////////
@description('The location for all resources.')
param location string

@description('The name of the Nat Gateway.')
param natGatewayName string

@description('The properties] of the Nat Gateway.')
param natGatewayProperties object

@description('The name of the Public IP Prefix.')
param publicIpPrefixName string

@description('The properties] of the Public IP Prefix.')
param publicIpPrefixProperties object

@description('The list of resource tags.')
param tags object

// Resource - Public Ip Prefix
//////////////////////////////////////////////////
resource publicIpPrefix 'Microsoft.Network/publicIPPrefixes@2022-09-01' = {
  name: publicIpPrefixName
  location: location
  tags: tags
  sku: {
    name: publicIpPrefixProperties.skuName
  }
  properties: {
    prefixLength: publicIpPrefixProperties.prefixLength
    publicIPAddressVersion: publicIpPrefixProperties.publicIPAddressVersion
  }
}

// Resource - Nat Gateway
//////////////////////////////////////////////////
resource natGateway 'Microsoft.Network/natGateways@2022-09-01' = {
  name: natGatewayName
  location: location
  tags: tags
  sku: {
    name: natGatewayProperties.skuName
  }
  properties: {
    idleTimeoutInMinutes: natGatewayProperties.idleTimeoutInMinutes
    publicIpPrefixes: [
      {
        id: publicIpPrefix.id
      }
    ]
  }
}

// Outputs
//////////////////////////////////////////////////
output natGatewayId string = natGateway.id
