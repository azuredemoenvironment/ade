// Parameters
//////////////////////////////////////////////////
@description('The name of the Route Table.')
param internetRouteTableName string

@description('The region location of deployment.')
param location string = resourceGroup().location

// Variables
//////////////////////////////////////////////////
var tags = {
  environment: 'production'
  function: 'networking'
  costCenter: 'it'
}

// Resource - Route Table
//////////////////////////////////////////////////
resource internetRouteTable 'Microsoft.Network/routeTables@2020-07-01' = {
  name: internetRouteTableName
  location: location
  tags: tags
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

// Outputs
//////////////////////////////////////////////////
output internetRouteTableId string = internetRouteTable.id
