// target scope
targetScope = 'subscription'

// parameters
param defaultPrimaryRegion string
param aliasRegion string
param monitorResourceGroupName string
param appConfigResourceGroupName string
param containerRegistryResourceGroupName string
param networkingResourceGroupName string
param jumpboxResourceGroupName string
param nTierResourceGroupName string
param vmssResourceGroupName string
param w10clientResourceGroupName string
param adminUserName string
param adminPassword string

// service name variables
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
var virtualNetwork001Name = 'vnet-ade-${aliasRegion}-001'
var managementSubnetName = 'snet-ade-${aliasRegion}-management'
var virtualNetwork002Name = 'vnet-ade-${aliasRegion}-002'
var appConfigName = 'appcs-ade-${aliasRegion}-001'
var containerRegistryName = replace('acr-ade-${aliasRegion}-001', '-', '')
var nTierWebSubnetName = 'snet-ade-${aliasRegion}-nTierWeb'
var nTierAppSubnetName = 'snet-ade-${aliasRegion}-nTierApp'
var vmssSubnetName = 'snet-ade-${aliasRegion}-vmss'
var clientServicesSubnetName = 'snet-ade-${aliasRegion}-clientServices'
var jumpboxPublicIpAddressName = 'pip-ade-${aliasRegion}-jumpbox01'
var jumpboxNICName = 'nic-ade-${aliasRegion}-jumpbox01'
var jumpboxPrivateIpAddress = '10.101.31.4'
var jumpboxName = 'vm-jumpbox01'
var jumpboxOSDiskName = 'osdisk-ade-${aliasRegion}-jumpbox01'
var proximityPlacementGroupAz1Name = 'ppg-ade-${aliasRegion}-ntier-az1'
var proximityPlacementGroupAz2Name = 'ppg-ade-${aliasRegion}-ntier-az2'
var proximityPlacementGroupAz3Name = 'ppg-ade-${aliasRegion}-ntier-az3'
var nTierAppLoadBalancerName = 'lbi-ade-${aliasRegion}-ntierapp'
var nTierAppLoadBalancerPrivateIpAddress = '10.102.2.4'
var nTierWeb01NICName = 'nic-ade-${aliasRegion}-ntierweb01'
var nTierWeb01PrivateIpAddress = '10.102.1.5'
var nTierWeb02NICName = 'nic-ade-${aliasRegion}-ntierweb02'
var nTierWeb02PrivateIpAddress = '10.102.1.6'
var nTierWeb03NICName = 'nic-ade-${aliasRegion}-ntierweb03'
var nTierWeb03PrivateIpAddress = '10.102.1.7'
var nTierApp01NICName = 'nic-ade-${aliasRegion}-ntierapp01'
var nTierApp01PrivateIpAddress = '10.102.2.5'
var nTierApp02NICName = 'nic-ade-${aliasRegion}-ntierapp02'
var nTierApp02PrivateIpAddress = '10.102.2.6'
var nTierApp03NICName = 'nic-ade-${aliasRegion}-ntierapp03'
var nTierApp03PrivateIpAddress = '10.102.2.7'
var nTierWeb01Name = 'vm-ntierweb01'
var nTierWeb01OSDiskName = 'disk-ade-${aliasRegion}-ntierweb01-os'
var nTierWeb02Name = 'vm-ntierweb02'
var nTierWeb02OSDiskName = 'disk-ade-${aliasRegion}-ntierweb02-os'
var nTierWeb03Name = 'vm-ntierweb03'
var nTierWeb03OSDiskName = 'disk-ade-${aliasRegion}-ntierweb03-os'
var nTierApp01Name = 'vm-ntierapp01'
var nTierApp01OSDiskName = 'disk-ade-${aliasRegion}-ntierapp01-os'
var nTierApp02Name = 'vm-ntierapp02'
var nTierApp02OSDiskName = 'disk-ade-${aliasRegion}-ntierapp02-os'
var nTierApp03Name = 'vm-ntierapp03'
var nTierApp03OSDiskName = 'disk-ade-${aliasRegion}-ntierapp03-os'
var vmssLoadBalancerPublicIpAddressName = 'pip-ade-${aliasRegion}-vmss01'
var vmssLoadBalancerName = 'lbe-ade-${aliasRegion}-vmss01'
var vmssName = 'vmss01'
var vmssNICName = 'nic-ade-${aliasRegion}-vmss01'
var w10ClientNICName = 'nic-ade-${aliasRegion}-w10client'
var w10ClientPrivateIpAddress = '10.102.21.4'
var w10ClientName = 'vm-w10client'
var w10ClientOSDiskName = 'disk-ade-${aliasRegion}-w10client-os'

// existing resources
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: logAnalyticsWorkspaceName
}

// resource - virtual network - virtual network 001
resource virtualNetwork001 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: virtualNetwork001Name
  resource managementSubnet 'subnets@2020-07-01' existing = {
    name: managementSubnetName
  }
}

// resource - virtual network - virtual network 002
resource virtualNetwork002 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: virtualNetwork002Name
  resource nTierWebSubnet 'subnets@2020-07-01' existing = {
    name: nTierWebSubnetName
  }
  resource nTierAppSubnet 'subnets@2020-07-01' existing = {
    name: nTierAppSubnetName
  }
  resource vmssSubnet 'subnets@2020-07-01' existing = {
    name: vmssSubnetName
  }
  resource clientServicesSubnet 'subnets@2020-07-01' existing = {
    name: clientServicesSubnetName
  }
}

// resource - app config
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2020-07-01-preview' existing = {
  scope: resourceGroup(appConfigResourceGroupName)
  name: appConfigName
}

// resource - app config
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' existing = {
  scope: resourceGroup(containerRegistryResourceGroupName)
  name: containerRegistryName
}

// module - jumpbox
module jumpBoxModule './azure_virtual_machines_jumpbox.bicep' = {
  scope: resourceGroup(jumpboxResourceGroupName)
  name: 'jumpBoxDeployment'
  params: {
    location: defaultPrimaryRegion
    adminUserName: adminUserName
    adminPassword: adminPassword
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    logAnalyticsWorkspaceCustomerId: logAnalyticsWorkspace.properties.customerId
    logAnalyticsWorkspaceKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
    managementSubnetId: virtualNetwork001::managementSubnet.id
    jumpboxPublicIpAddressName: jumpboxPublicIpAddressName
    jumpboxNICName: jumpboxNICName
    jumpboxPrivateIpAddress: jumpboxPrivateIpAddress
    jumpboxName: jumpboxName
    jumpboxOSDiskName: jumpboxOSDiskName
  }
}

// module - ntier
module nTierModule './azure_virtual_machines_ntier.bicep' = {
  scope: resourceGroup(nTierResourceGroupName)
  name: 'nTierDeployment'
  params: {
    location: defaultPrimaryRegion
    adminUserName: adminUserName
    adminPassword: adminPassword
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    logAnalyticsWorkspaceCustomerId: logAnalyticsWorkspace.properties.customerId
    logAnalyticsWorkspaceKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
    appConfigResourceGroupName: appConfigResourceGroupName
    appConfigName: appConfig.name
    appConfigConnectionString: first(listKeys(appConfig.id, appConfig.apiVersion).value).connectionString
    acrServerName: containerRegistryName
    acrPassword: first(listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords).value
    nTierWebSubnetId: virtualNetwork002::nTierWebSubnet.id
    nTierAppSubnetId: virtualNetwork002::nTierAppSubnet.id
    proximityPlacementGroupAz1Name: proximityPlacementGroupAz1Name
    proximityPlacementGroupAz2Name: proximityPlacementGroupAz2Name
    proximityPlacementGroupAz3Name: proximityPlacementGroupAz3Name
    nTierAppLoadBalancerName: nTierAppLoadBalancerName
    nTierAppLoadBalancerPrivateIpAddress: nTierAppLoadBalancerPrivateIpAddress
    nTierWeb01NICName: nTierWeb01NICName
    nTierWeb01PrivateIpAddress: nTierWeb01PrivateIpAddress
    nTierWeb02NICName: nTierWeb02NICName
    nTierWeb02PrivateIpAddress: nTierWeb02PrivateIpAddress
    nTierWeb03NICName: nTierWeb03NICName
    nTierWeb03PrivateIpAddress: nTierWeb03PrivateIpAddress
    nTierApp01NICName: nTierApp01NICName
    nTierApp01PrivateIpAddress: nTierApp01PrivateIpAddress
    nTierApp02NICName: nTierApp02NICName
    nTierApp02PrivateIpAddress: nTierApp02PrivateIpAddress
    nTierApp03NICName: nTierApp03NICName
    nTierApp03PrivateIpAddress: nTierApp03PrivateIpAddress
    nTierWeb01Name: nTierWeb01Name
    nTierWeb01OSDiskName: nTierWeb01OSDiskName
    nTierWeb02Name: nTierWeb02Name
    nTierWeb02OSDiskName: nTierWeb02OSDiskName
    nTierWeb03Name: nTierWeb03Name
    nTierWeb03OSDiskName: nTierWeb03OSDiskName
    nTierApp01Name: nTierApp01Name
    nTierApp01OSDiskName: nTierApp01OSDiskName
    nTierApp02Name: nTierApp02Name
    nTierApp02OSDiskName: nTierApp02OSDiskName
    nTierApp03Name: nTierApp03Name
    nTierApp03OSDiskName: nTierApp03OSDiskName
  }
}

// module - vmss
module vmssModule 'azure_virtual_machines_vmss.bicep' = {
  scope: resourceGroup(vmssResourceGroupName)
  name: 'vmssDeployment'
  params: {
    location: defaultPrimaryRegion
    adminUserName: adminUserName
    adminPassword: adminPassword
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    logAnalyticsWorkspaceCustomerId: logAnalyticsWorkspace.properties.customerId
    logAnalyticsWorkspaceKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
    vmssSubnetId: virtualNetwork002::vmssSubnet.id
    vmssLoadBalancerPublicIpAddressName: vmssLoadBalancerPublicIpAddressName
    vmssLoadBalancerName: vmssLoadBalancerName
    vmssName: vmssName
    vmssNICName: vmssNICName
  }
}

// module - windows 10 client
module w10ClientModule './azure_virtual_machines_w10client.bicep' = {
  scope: resourceGroup(w10clientResourceGroupName)
  name: 'w10ClientDeployment'
  params: {
    location: defaultPrimaryRegion
    adminUserName: adminUserName
    adminPassword: adminPassword
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    clientServicesSubnetId: virtualNetwork002::clientServicesSubnet.id
    w10ClientNICName: w10ClientNICName
    w10ClientPrivateIpAddress: w10ClientPrivateIpAddress
    w10ClientName: w10ClientName
    w10ClientOSDiskName: w10ClientOSDiskName
  }
}
