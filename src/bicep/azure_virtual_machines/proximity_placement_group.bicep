// Parameters
//////////////////////////////////////////////////
@description('The location for all resources.')
param location string

@description('The array of Proximity Placement Groups.')
param proximityPlacementGroups array

@description('The list of Resource tags')
param tags object

// Resource - Proximity Placement Group
//////////////////////////////////////////////////
resource ppg 'Microsoft.Compute/proximityPlacementGroups@2022-11-01' = [for (proximityPlacementGroup, i) in proximityPlacementGroups: {
  name: proximityPlacementGroup.name
  location: location
  tags: tags
  properties: {
    proximityPlacementGroupType: proximityPlacementGroup.proximityPlacementGroupType
  }
}]

// Outputs
//////////////////////////////////////////////////
output ppgProperties array = [for (proximityPlacementGroup, i) in proximityPlacementGroups: {
  name: ppg[i].name
  resourceId: ppg[i].id
}]
