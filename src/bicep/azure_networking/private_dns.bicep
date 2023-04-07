// Parameters
//////////////////////////////////////////////////
@description('The name of the Azure App Service Private DNS Zone.')
param appServicePrivateDnsZoneName string

@description('The name of the Azure Sql Private DNS Zone.')
param azureSqlPrivateDnsZoneName string

@description('The ID of the hub Virtual Network.')
param hubVirtualNetworkId string

@description('The name of the hub Virtual Network.')
param hubVirtualNetworkName string

@description('The ID of the spoke Virtual Network.')
param spokeVirtualNetworkId string

@description('The name of the spoke Virtual Network.')
param spokeVirtualNetworkName string

@description('The list of resource tags.')
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
  name: '${hubVirtualNetworkName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: hubVirtualNetworkId
    }
  }
}

// Resource Virtual Network Link - Privatelink.Azurewebsites.Net To Virtual Network 002
//////////////////////////////////////////////////
resource vnetLink02 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: appServicePrivateDnsZone
  name: '${spokeVirtualNetworkName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: spokeVirtualNetworkId
    }
  }
}

// Resource Virtual Network Link - Privatelink.Database.Windows.Net to hub Virtual Network
//////////////////////////////////////////////////
resource vnetLink11 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: azureSqlPrivateDnsZone
  name: '${hubVirtualNetworkName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: hubVirtualNetworkId
    }
  }
}

// Resource Virtual Network Link - Privatelink.Database.Windows.Net to spoke Virtual Network
//////////////////////////////////////////////////
resource vnetLink12 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: azureSqlPrivateDnsZone
  name: '${spokeVirtualNetworkName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: spokeVirtualNetworkId
    }
  }
}
