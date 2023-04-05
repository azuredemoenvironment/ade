// Parameters
//////////////////////////////////////////////////
@description('The name of the Azure App Service Private DNS Zone.')
param appServicePrivateDnsZoneName string

@description('The name of the Azure Sql Private DNS Zone.')
param azureSqlPrivateDnsZoneName string

@description('The ID of Virtual Network 001.')
param virtualNetwork001Id string

@description('The name of Virtual Network 001.')
param virtualNetwork001Name string

@description('The ID of Virtual Network 002.')
param virtualNetwork002Id string

@description('The name of Virtual Network 002.')
param virtualNetwork002Name string

@description('The list of Resource tags')
param tags object

// Resource - Private Dns Zone - Privatelink.Azurewebsites.Net
//////////////////////////////////////////////////
resource appServicePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: appServicePrivateDnsZoneName
  location: 'global'
  tags: tags
}

// Resource - Private Dns Zone - Privatelink.Database.Windows.Net
//////////////////////////////////////////////////
resource azureSqlPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: azureSqlPrivateDnsZoneName
  location: 'global'
  tags: tags
}

// Resource - Private Dns Zone - Virtual Network Link - privatelink.azurewebsites.net to Virtual Network
//////////////////////////////////////////////////
resource vnetLink01 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: appServicePrivateDnsZone
  name: '${virtualNetwork001Name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork001Id
    }
  }
}

// Resource Virtual Network Link - Privatelink.Azurewebsites.Net To Virtual Network 002
//////////////////////////////////////////////////
resource vnetLink02 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: appServicePrivateDnsZone
  name: '${virtualNetwork002Name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork002Id
    }
  }
}

// Resource Virtual Network Link - Privatelink.Database.Windows.Net To Virtual Network 001
//////////////////////////////////////////////////
resource vnetLink11 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: azureSqlPrivateDnsZone
  name: '${virtualNetwork001Name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork001Id
    }
  }
}

// Resource Virtual Network Link - Privatelink.Database.Windows.Net To Virtual Network 002
//////////////////////////////////////////////////
resource vnetLink12 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: azureSqlPrivateDnsZone
  name: '${virtualNetwork002Name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork002Id
    }
  }
}
