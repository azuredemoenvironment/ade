// target scope
targetScope = 'subscription'

// parameters
param defaultPrimaryRegion string
param aliasRegion string
param monitorResourceGroupName string
param networkingResourceGroupName string
param jumpboxResourceGroupName string
param nTierResourceGroupName string
param vmssResourceGroupName string
param w10clientResourceGroupName string
param adminUserName string
param adminPassword string

// existing resources
// variables - log analytics workspace
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
// variables - virtual network - virtual network 001
var virtualNetwork001Name = 'vnet-ade-${aliasRegion}-001'
var managementSubnetName = 'snet-management'
// variables - virtual network - virtual network 002
var virtualNetwork002Name = 'vnet-ade-${aliasRegion}-002'
var nTierWebSubnetName = 'snet-nTierWeb'
var nTierAppSubnetName = 'snet-nTierApp'
var vmssSubnetName = 'snet-vmss'
var clientServicesSubnetName = 'snet-clientServices'

// module - jumpbox
// variables
var jumpboxPublicIpAddressName = 'pip-ade-${aliasRegion}-jumpbox01'
var jumpboxNICName = 'nic-ade-${aliasRegion}-jumpbox01'
var jumpboxPrivateIpAddress = '10.101.31.4'
var jumpboxName = 'vm-jumpbox01'
var jumpboxOSDiskName = 'osdisk-ade-${aliasRegion}-jumpbox01'
// module deployment
module jumpBoxModule './azure_virtual_machines_jumpbox.bicep' = {
  scope: resourceGroup(jumpboxResourceGroupName)
  name: 'jumpBoxDeployment'
  params: {
    location: defaultPrimaryRegion
    adminUserName: adminUserName
    adminPassword: adminPassword
    monitorResourceGroupName: monitorResourceGroupName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    networkingResourceGroupName: networkingResourceGroupName
    virtualNetwork001Name: virtualNetwork001Name
    managementSubnetName: managementSubnetName
    jumpboxPublicIpAddressName: jumpboxPublicIpAddressName
    jumpboxNICName: jumpboxNICName
    jumpboxPrivateIpAddress: jumpboxPrivateIpAddress
    jumpboxName: jumpboxName
    jumpboxOSDiskName: jumpboxOSDiskName
  }
}

// module - ntier
// variables
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
// module deployment
module nTierModule './azure_virtual_machines_ntier.bicep' = {
  scope: resourceGroup(nTierResourceGroupName)
  name: 'nTierDeployment'
  params: {
    location: defaultPrimaryRegion
    adminUserName: adminUserName
    adminPassword: adminPassword
    monitorResourceGroupName: monitorResourceGroupName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    networkingResourceGroupName: networkingResourceGroupName
    virtualNetwork002Name: virtualNetwork002Name
    nTierWebSubnetName: nTierWebSubnetName
    nTierAppSubnetName: nTierAppSubnetName
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
// variables
var vmssLoadBalancerPublicIpAddressName = 'pip-ade-${aliasRegion}-vmss01'
var vmssLoadBalancerName = 'lbe-ade-${aliasRegion}-vmss01'
var vmssName = 'vmss01'
var vmssNICName = 'nic-ade-${aliasRegion}-vmss01'
// module deployment
module vmssModule 'azure_virtual_machines_vmss.bicep' = {
  scope: resourceGroup(vmssResourceGroupName)
  name: 'vmssDeployment'
  params: {
    location: defaultPrimaryRegion
    adminUserName: adminUserName
    adminPassword: adminPassword
    monitorResourceGroupName: monitorResourceGroupName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    networkingResourceGroupName: networkingResourceGroupName
    virtualNetwork002Name: virtualNetwork002Name
    vmssSubnetName: vmssSubnetName
    vmssLoadBalancerPublicIpAddressName: vmssLoadBalancerPublicIpAddressName
    vmssLoadBalancerName: vmssLoadBalancerName
    vmssName: vmssName
    vmssNICName: vmssNICName
  }
}

// module - windows 10 client
// variables
var w10ClientNICName = 'nic-ade-${aliasRegion}-w10client'
var w10ClientPrivateIpAddress = '10.102.21.4'
var w10ClientName = 'vm-w10client'
var w10ClientOSDiskName = 'disk-ade-${aliasRegion}-w10client-os'
// module deployment
module w10ClientModule './azure_virtual_machines_w10client.bicep' = {
  scope: resourceGroup(w10clientResourceGroupName)
  name: 'w10ClientDeployment'
  params: {
    location: defaultPrimaryRegion
    adminUserName: adminUserName
    adminPassword: adminPassword
    monitorResourceGroupName: monitorResourceGroupName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    networkingResourceGroupName: networkingResourceGroupName
    virtualNetwork002Name: virtualNetwork002Name
    clientServicesSubnetName: clientServicesSubnetName
    w10ClientNICName: w10ClientNICName
    w10ClientPrivateIpAddress: w10ClientPrivateIpAddress
    w10ClientName: w10ClientName
    w10ClientOSDiskName: w10ClientOSDiskName
  }
}
