// Parameters
//////////////////////////////////////////////////
@description('The array of Action Groups.')
param actionGroups array

@description('The list of resource tags.')
param tags object

// Resource - Action Group
//////////////////////////////////////////////////
resource ag 'Microsoft.Insights/actionGroups@2023-01-01' = [for (actionGroup, i) in actionGroups: {
  name: actionGroup.name
  location: 'global'
  tags: tags
  properties: {
    groupShortName: actionGroup.properties.groupShortName
    enabled: actionGroup.properties.enabled
    emailReceivers: actionGroup.properties.emailReceivers
  }
}]

// Outputs - Action Group
//////////////////////////////////////////////////
output actionGroupIds array = [for (actionGroup, i) in actionGroups: {
  actionGroupId: ag[i].id
}]
