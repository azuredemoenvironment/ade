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
    enabled: actionGroup.enabled
    groupShortName: actionGroup.groupShortName
    emailReceivers: [
      {
        name: actionGroup.emailReceiversName
        emailAddress: actionGroup.emailAddress
        useCommonAlertSchema: actionGroup.useCommonAlertSchema
      }
    ]
  }
}]

// Outputs - Action Group
//////////////////////////////////////////////////
output actionGroupIds array = [for (actionGroup, i) in actionGroups: {
  actionGroupId: ag[i].id
}]
