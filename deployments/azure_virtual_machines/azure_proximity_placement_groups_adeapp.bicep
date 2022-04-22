// Parameters
//////////////////////////////////////////////////
@description('The location for all resources.')
param location string

@description('The name of the Proximity Placement Group for Availability Zone 1.')
param proximityPlacementGroupAz1Name string

@description('The name of the Proximity Placement Group for Availability Zone 2.')
param proximityPlacementGroupAz2Name string

@description('The name of the Proximity Placement Group for Availability Zone 3.')
param proximityPlacementGroupAz3Name string

// Variables
//////////////////////////////////////////////////
var tags = {
  environment: 'production'
  function: 'ppg'
  costCenter: 'it'
}

// Resource - Proximity Placement Group - Availability Zone 1
//////////////////////////////////////////////////
resource proximityPlacementGroupAz1 'Microsoft.Compute/proximityPlacementGroups@2020-12-01' = {
  name: proximityPlacementGroupAz1Name
  location: location
  tags: tags
  properties: {
    proximityPlacementGroupType: 'Standard'
  }
}

// Resource - Proximity Placement Group - Availability Zone 2
//////////////////////////////////////////////////
resource proximityPlacementGroupAz2 'Microsoft.Compute/proximityPlacementGroups@2020-12-01' = {
  name: proximityPlacementGroupAz2Name
  location: location
  tags: tags
  properties: {
    proximityPlacementGroupType: 'Standard'
  }
}

// Resource - Proximity Placement Group - Availability Zone 3
//////////////////////////////////////////////////
resource proximityPlacementGroupAz3 'Microsoft.Compute/proximityPlacementGroups@2020-12-01' = {
  name: proximityPlacementGroupAz3Name
  location: location
  tags: tags
  properties: {
    proximityPlacementGroupType: 'Standard'
  }
}

// Outputs
//////////////////////////////////////////////////
output proximityPlacementGroupAz1Id string = proximityPlacementGroupAz1.id
output proximityPlacementGroupAz2Id string = proximityPlacementGroupAz2.id
output proximityPlacementGroupAz3Id string = proximityPlacementGroupAz3.id
