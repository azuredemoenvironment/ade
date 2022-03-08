// Parameters
//////////////////////////////////////////////////
@description('The region location of deployment.')
param location string = resourceGroup().location

// Variables
//////////////////////////////////////////////////
var tags = {
  environment: 'production'
  function: 'networking'
  costCenter: 'it'
}

// Resource - Network Watcher
//////////////////////////////////////////////////
resource networkWatcher 'Microsoft.Network/networkWatchers@2021-03-01' = {
  name: 'NetworkWatcher_${toLower(location)}'
  location: location
  tags: tags
}
