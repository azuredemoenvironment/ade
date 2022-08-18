// Parameters
//////////////////////////////////////////////////
@description('The name of the Route Table.')
param internetRouteTableName string

@description('The location for all resources.')
param location string

@description('The list of Resource tags')
param tags object

// Resource - Route Table
//////////////////////////////////////////////////
resource internetRouteTable 'Microsoft.Network/routeTables@2022-01-01' = {
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
