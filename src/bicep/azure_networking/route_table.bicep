// Parameters
//////////////////////////////////////////////////
@description('The location for all resources.')
param location string

@description('The array of routes.')
param routes array

@description('The name of the Route Table.')
param routeTableName string

@description('The list of resource tags.')
param tags object

// Resource - Route Table
//////////////////////////////////////////////////
resource routeTable 'Microsoft.Network/routeTables@2022-01-01' = {
  name: routeTableName
  location: location
  tags: tags
  properties: {
    routes: [for route in routes: {
      name: route.name
      properties: {
        addressPrefix: route.addressPrefix
        nextHopType: route.nextHopType
        nextHopIpAddress: route.nextHopIpAddress
      }
    }]
  }
}

// Outputs
//////////////////////////////////////////////////
output routeTableId string = routeTable.id
