// parameters
param virtualNetwork001Name string
param virtualNetwork002Name string
param appServicePrivateDnsZoneName string
param azureSQLPrivateDnsZoneName string
param virtualNetwork001Id string
param virtualNetwork002Id string

// variables
var environmentName = 'production'
var functionName = 'networking'
var costCenterName = 'it'

// resource - private dns zone - privatelink.azurewebsites.net
resource appServicePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: appServicePrivateDnsZoneName
  location: 'global'
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
}

// resource - private dns zone - privatelink.database.windows.net
resource azureSQLPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: azureSQLPrivateDnsZoneName
  location: 'global'
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
}

// resource virtual network link - privatelink.azurewebsites.net to virtual network 001
resource vnetLink01 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${appServicePrivateDnsZone.name}/${virtualNetwork001Name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork001Id
    }
  }
}

// resource virtual network link - privatelink.azurewebsites.net to virtual network 002
resource vnetLink02 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${appServicePrivateDnsZone.name}/${virtualNetwork002Name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork002Id
    }
  }
}

// resource virtual network link - privatelink.database.windows.net to virtual network 001
resource vnetLink11 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${azureSQLPrivateDnsZone.name}/${virtualNetwork001Name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork001Id
    }
  }
}

// resource virtual network link - privatelink.database.windows.net to virtual network 002
resource vnetLink12 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${azureSQLPrivateDnsZone.name}/${virtualNetwork002Name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork002Id
    }
  }
}
