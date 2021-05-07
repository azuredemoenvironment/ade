param virtualNetwork01ResourceGroupName string {
  metadata: {
    description: 'The Name of Virtual Network 01 Resource Group.'
  }
}
param virtualNetwork01Name string {
  metadata: {
    description: 'The Name of Virtual Network 01.'
  }
}
param virtualNetwork02ResourceGroupName string {
  metadata: {
    description: 'The Name of Virtual Network 02 Resource Group.'
  }
}
param virtualNetwork02Name string {
  metadata: {
    description: 'The Name of Virtual Network 02.'
  }
}
param virtualNetwork03ResourceGroupName string {
  metadata: {
    description: 'The Name of Virtual Network 03 Resource Group.'
  }
}
param virtualNetwork03Name string {
  metadata: {
    description: 'The Name of Virtual Network 03.'
  }
}

var appServicePrivateDnsZoneName_var = 'privatelink.azurewebsites.net'
var azureSQLprivateDnsZoneName_var = 'privatelink.database.windows.net'
var virtualNetwork01Id = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${virtualNetwork01ResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${virtualNetwork01Name}'
var virtualNetwork02Id = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${virtualNetwork02ResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${virtualNetwork02Name}'
var virtualNetwork03Id = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${virtualNetwork03ResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${virtualNetwork03Name}'

resource appServicePrivateDnsZoneName 'Microsoft.Network/privateDnsZones@2020-01-01' = {
  name: appServicePrivateDnsZoneName_var
  location: 'global'
  properties: ''
  dependsOn: []
}

resource azureSQLprivateDnsZoneName 'Microsoft.Network/privateDnsZones@2020-01-01' = {
  name: azureSQLprivateDnsZoneName_var
  location: 'global'
  properties: ''
  dependsOn: []
}

resource appServicePrivateDnsZoneName_virtualNetwork01Name_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-01-01' = {
  name: '${appServicePrivateDnsZoneName.name}/${virtualNetwork01Name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork01Id
    }
  }
}

resource appServicePrivateDnsZoneName_virtualNetwork02Name_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-01-01' = {
  name: '${appServicePrivateDnsZoneName.name}/${virtualNetwork02Name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork02Id
    }
  }
}

resource appServicePrivateDnsZoneName_virtualNetwork03Name_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-01-01' = {
  name: '${appServicePrivateDnsZoneName.name}/${virtualNetwork03Name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork03Id
    }
  }
}

resource azureSQLprivateDnsZoneName_virtualNetwork01Name_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-01-01' = {
  name: '${azureSQLprivateDnsZoneName.name}/${virtualNetwork01Name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork01Id
    }
  }
  dependsOn: [
    resourceId('Microsoft.Network/privateDnsZones/virtualNetworkLinks', appServicePrivateDnsZoneName_var, '${virtualNetwork01Name}-link')
  ]
}

resource azureSQLprivateDnsZoneName_virtualNetwork02Name_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-01-01' = {
  name: '${azureSQLprivateDnsZoneName.name}/${virtualNetwork02Name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork02Id
    }
  }
  dependsOn: [
    resourceId('Microsoft.Network/privateDnsZones/virtualNetworkLinks', appServicePrivateDnsZoneName_var, '${virtualNetwork02Name}-link')
  ]
}

resource azureSQLprivateDnsZoneName_virtualNetwork03Name_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-01-01' = {
  name: '${azureSQLprivateDnsZoneName.name}/${virtualNetwork03Name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork03Id
    }
  }
  dependsOn: [
    resourceId('Microsoft.Network/privateDnsZones/virtualNetworkLinks', appServicePrivateDnsZoneName_var, '${virtualNetwork03Name}-link')
  ]
}