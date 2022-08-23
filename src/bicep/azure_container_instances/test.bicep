@description('This is the name of the network security group')
param networkSecurityGroupName string

@description('Location where the network security group resource will be created.')
param location string

resource networkSecurityGroupName_resource 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
  }
  tags: {
  }
}