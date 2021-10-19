// parameters
param aliasRegion string
param networkingResourceGroupName string
param jumpboxResourceGroupName string
param adeAppVmResourceGroupName string

param adeAppFrontEndAppServiceARecordName string
param adeAppApiGatewayAppServiceARecordName string
param inspectorGadgetAppServiceARecordName string
param jumpboxARecordName string
param nTierARecordName string

// existing resources
//variables
var applicationGatewayPublicIpAddressName = 'pip-ade-${aliasRegion}-appgw001'
// resource - public ip address - application gateway
resource applicationGatewayPublicIpAddress 'Microsoft.Network/publicIPAddresses@2020-06-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: applicationGatewayPublicIpAddressName
}
// variables
var jumpboxPublicIpAddressName = 'pip-ade-${aliasRegion}-jumpbox01'
// resource - network interface - jumpbox
resource jumpboxPublicIpAddress 'Microsoft.Network/publicIPAddresses@2020-06-01' existing = {
  scope: resourceGroup(adeAppVmResourceGroupName)
  name: jumpboxPublicIpAddressName
}

// resource - public dns zone a record - adeAppFrontEndAppService
resource adeAppFrontEndAppServiceARecord 'Microsoft.Network/dnsZones/A@2018-05-01' = {
  name: adeAppFrontEndAppServiceARecordName
  properties: {
    TTL: 3600
    ARecords: [
      {
        ipv4Address: applicationGatewayPublicIpAddress.properties.ipAddress
      }
    ]
  }
}

// resource - public dns zone a record - adeApiGatewayAppService
resource adeAppApiGatewayAppServiceARecord 'Microsoft.Network/dnsZones/A@2018-05-01' = {
  name: adeAppApiGatewayAppServiceARecordName
  properties: {
    TTL: 3600
    ARecords: [
      {
        ipv4Address: applicationGatewayPublicIpAddress.properties.ipAddress
      }
    ]
  }
}

// resource - public dns zone a record - inspectorGadgetAppService
resource inspectorGadgetAppServiceARecord 'Microsoft.Network/dnsZones/A@2018-05-01' = {
  name: inspectorGadgetAppServiceARecordName
  properties: {
    TTL: 3600
    ARecords: [
      {
        ipv4Address: applicationGatewayPublicIpAddress.properties.ipAddress
      }
    ]
  }
}

// resource - public dns zone a record - jumpbox
resource jumpboxARecord 'Microsoft.Network/dnsZones/A@2018-05-01' = {
  name: jumpboxARecordName
  properties: {
    TTL: 3600
    ARecords: [
      {
        ipv4Address: jumpboxPublicIpAddress.properties.ipAddress
      }
    ]
  }
}

// resource - public dns zone a record - nTier
resource nTierARecord 'Microsoft.Network/dnsZones/A@2018-05-01' = {
  name: nTierARecordName
  properties: {
    TTL: 3600
    ARecords: [
      {
        ipv4Address: applicationGatewayPublicIpAddress.properties.ipAddress
      }
    ]
  }
}
