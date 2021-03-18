// parameters
param location string = resourceGroup().location
param aliasRegion string

// variables
var internetRouteTableName = 'route-ade-${aliasRegion}-internet'
var environmentName = 'production'
var functionName = 'networking'
var costCenterName = 'it'

// resource - route table
resource internetRouteTable 'Microsoft.Network/routeTables@2020-06-01' = {
  name: internetRouteTableName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    routes: [
      {
        name: 'toInternet'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.101.0.4'
        }
      }
    ]
  }
}

// outputs
output internetRouteTableId string = internetRouteTable.id