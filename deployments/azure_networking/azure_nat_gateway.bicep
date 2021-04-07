// parameters
param location string
param natGatewayPublicIPPrefixName string
param natGatewayName string

// variables
var environmentName = 'production'
var functionName = 'networking'
var costCenterName = 'it'

// resource - public ip prefix
resource natGatewaypublicIPPrefix 'Microsoft.Network/publicIPPrefixes@2020-06-01' = {
  name: natGatewayPublicIPPrefixName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    prefixLength: 31
    publicIPAddressVersion: 'IPv4'
  }
}

// resource - nat gateway
resource natGateway 'Microsoft.Network/natGateways@2020-06-01' = {
  name: natGatewayName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
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

// outputs
output natGatewayId string = natGateway.id
output natGatewaypublicIPPrefixId string = natGatewaypublicIPPrefix.id
