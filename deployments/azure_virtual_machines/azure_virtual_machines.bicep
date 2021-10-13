// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'

// Parameters
//////////////////////////////////////////////////
@description('The name of the admin user.')
param adminUserName string

@description('The user alias and Azure region defined from user input.')
param aliasRegion string

@description('The selected Azure region for deployment.')
param azureRegion string

// Global Variables
//////////////////////////////////////////////////
// Resource Groups
var appConfigResourceGroupName = 'rg-ade-${aliasRegion}-appconfiguration'
var containerRegistryResourceGroupName = 'rg-ade-${aliasRegion}-containerregistry'
var jumpboxResourceGroupName = 'rg-ade-${aliasRegion}-jumpbox'
var keyVaultResourceGroupName = 'rg-ade-${aliasRegion}-keyvault'
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
var networkingResourceGroupName = 'rg-ade-${aliasRegion}-networking'
var nTierResourceGroupName = 'rg-ade-${aliasRegion}-ntier'
var vmssResourceGroupName = 'rg-ade-${aliasRegion}-vmss'
var w10clientResourceGroupName = 'rg-ade-${aliasRegion}-w10client'
// Resources
var appConfigName = 'appcs-ade-${aliasRegion}-001'
var clientServicesSubnetName = 'snet-ade-${aliasRegion}-clientServices'
var containerRegistryName = replace('acr-ade-${aliasRegion}-001', '-', '')
var jumpboxName = 'vm-jumpbox01'
var jumpboxNICName = 'nic-ade-${aliasRegion}-jumpbox01'
var jumpboxOSDiskName = 'osdisk-ade-${aliasRegion}-jumpbox01'
var jumpboxPrivateIpAddress = '10.101.31.4'
var jumpboxPublicIpAddressName = 'pip-ade-${aliasRegion}-jumpbox01'
var keyVaultName = 'kv-ade-${aliasRegion}-001'
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
var managementSubnetName = 'snet-ade-${aliasRegion}-management'
var nTierApp01Name = 'vm-ntierapp01'
var nTierApp01NICName = 'nic-ade-${aliasRegion}-ntierapp01'
var nTierApp01OSDiskName = 'disk-ade-${aliasRegion}-ntierapp01-os'
var nTierApp01PrivateIpAddress = '10.102.2.5'
var nTierApp02Name = 'vm-ntierapp02'
var nTierApp02NICName = 'nic-ade-${aliasRegion}-ntierapp02'
var nTierApp02OSDiskName = 'disk-ade-${aliasRegion}-ntierapp02-os'
var nTierApp02PrivateIpAddress = '10.102.2.6'
var nTierApp03Name = 'vm-ntierapp03'
var nTierApp03NICName = 'nic-ade-${aliasRegion}-ntierapp03'
var nTierApp03OSDiskName = 'disk-ade-${aliasRegion}-ntierapp03-os'
var nTierApp03PrivateIpAddress = '10.102.2.7'
var nTierAppLoadBalancerName = 'lbi-ade-${aliasRegion}-ntierapp'
var nTierAppLoadBalancerPrivateIpAddress = '10.102.2.4'
var nTierAppSubnetName = 'snet-ade-${aliasRegion}-nTierApp'
var nTierWeb01Name = 'vm-ntierweb01'
var nTierWeb01NICName = 'nic-ade-${aliasRegion}-ntierweb01'
var nTierWeb01OSDiskName = 'disk-ade-${aliasRegion}-ntierweb01-os'
var nTierWeb01PrivateIpAddress = '10.102.1.5'
var nTierWeb02Name = 'vm-ntierweb02'
var nTierWeb02NICName = 'nic-ade-${aliasRegion}-ntierweb02'
var nTierWeb02OSDiskName = 'disk-ade-${aliasRegion}-ntierweb02-os'
var nTierWeb02PrivateIpAddress = '10.102.1.6'
var nTierWeb03Name = 'vm-ntierweb03'
var nTierWeb03NICName = 'nic-ade-${aliasRegion}-ntierweb03'
var nTierWeb03OSDiskName = 'disk-ade-${aliasRegion}-ntierweb03-os'
var nTierWeb03PrivateIpAddress = '10.102.1.7'
var nTierWebSubnetName = 'snet-ade-${aliasRegion}-nTierWeb'
var proximityPlacementGroupAz1Name = 'ppg-ade-${aliasRegion}-ntier-az1'
var proximityPlacementGroupAz2Name = 'ppg-ade-${aliasRegion}-ntier-az2'
var proximityPlacementGroupAz3Name = 'ppg-ade-${aliasRegion}-ntier-az3'
var virtualNetwork001Name = 'vnet-ade-${aliasRegion}-001'
var virtualNetwork002Name = 'vnet-ade-${aliasRegion}-002'
var vmssLoadBalancerName = 'lbe-ade-${aliasRegion}-vmss01'
var vmssLoadBalancerPublicIpAddressName = 'pip-ade-${aliasRegion}-vmss01'
var vmssName = 'vmss01'
var vmssNICName = 'nic-ade-${aliasRegion}-vmss01'
var vmssSubnetName = 'snet-ade-${aliasRegion}-vmss'
var w10ClientName = 'vm-w10client'
var w10ClientNICName = 'nic-ade-${aliasRegion}-w10client'
var w10ClientOSDiskName = 'disk-ade-${aliasRegion}-w10client-os'
var w10ClientPrivateIpAddress = '10.102.21.4'

// Existing Resource - App Config
//////////////////////////////////////////////////
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2020-07-01-preview' existing = {
  scope: resourceGroup(appConfigResourceGroupName)
  name: appConfigName
}

// Resource - Container Registry
//////////////////////////////////////////////////
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' existing = {
  scope: resourceGroup(containerRegistryResourceGroupName)
  name: containerRegistryName
}

// Existing Resource - Key Vault
//////////////////////////////////////////////////
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  scope: resourceGroup(keyVaultResourceGroupName)
  name: keyVaultName
}

// Existing Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: logAnalyticsWorkspaceName
}

// Existing Resource - Virtual Network - Virtual Network 001
//////////////////////////////////////////////////
resource virtualNetwork001 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: virtualNetwork001Name
  resource managementSubnet 'subnets@2020-07-01' existing = {
    name: managementSubnetName
  }
}

// Existing Resource - Virtual Network - Virtual Network 002
//////////////////////////////////////////////////
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

// Resource Group - Jumpbox
//////////////////////////////////////////////////
resource jumpboxResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: jumpboxResourceGroupName
  location: azureRegion
}

// Resource Group - Ntier
//////////////////////////////////////////////////
resource nTierResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: nTierResourceGroupName
  location: azureRegion
}

// Resource Group - Vmss
//////////////////////////////////////////////////
resource vmssResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: vmssResourceGroupName
  location: azureRegion
}

// Resource Group - W10client
//////////////////////////////////////////////////
resource w10clientResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: w10clientResourceGroupName
  location: azureRegion
}

// Module - Jumpbox
//////////////////////////////////////////////////
module jumpBoxModule './azure_virtual_machines_jumpbox.bicep' = {
  scope: resourceGroup(jumpboxResourceGroupName)
  name: 'jumpBoxDeployment'
  dependsOn: [
    jumpboxResourceGroup
  ]
  params: {
    adminPassword: keyVault.getSecret('resourcePassword')
    adminUserName: adminUserName
    jumpboxName: jumpboxName
    jumpboxNICName: jumpboxNICName
    jumpboxOSDiskName: jumpboxOSDiskName
    jumpboxPrivateIpAddress: jumpboxPrivateIpAddress
    jumpboxPublicIpAddressName: jumpboxPublicIpAddressName
    logAnalyticsWorkspaceCustomerId: logAnalyticsWorkspace.properties.customerId
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    logAnalyticsWorkspaceKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
    managementSubnetId: virtualNetwork001::managementSubnet.id
  }
}

// Module - Ntier
//////////////////////////////////////////////////
module nTierModule './azure_virtual_machines_ntier.bicep' = {
  scope: resourceGroup(nTierResourceGroupName)
  name: 'nTierDeployment'
  dependsOn: [
    nTierResourceGroup
  ]
  params: {
    acrPassword: first(listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords).value
    acrServerName: containerRegistryName
    adminPassword: keyVault.getSecret('resourcePassword')
    adminUserName: adminUserName
    appConfigConnectionString: first(listKeys(appConfig.id, appConfig.apiVersion).value).connectionString
    appConfigName: appConfig.name
    appConfigResourceGroupName: appConfigResourceGroupName
    logAnalyticsWorkspaceCustomerId: logAnalyticsWorkspace.properties.customerId
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    logAnalyticsWorkspaceKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
    nTierApp01Name: nTierApp01Name
    nTierApp01NICName: nTierApp01NICName
    nTierApp01OSDiskName: nTierApp01OSDiskName
    nTierApp01PrivateIpAddress: nTierApp01PrivateIpAddress
    nTierApp02Name: nTierApp02Name
    nTierApp02NICName: nTierApp02NICName
    nTierApp02OSDiskName: nTierApp02OSDiskName
    nTierApp02PrivateIpAddress: nTierApp02PrivateIpAddress
    nTierApp03Name: nTierApp03Name
    nTierApp03NICName: nTierApp03NICName
    nTierApp03OSDiskName: nTierApp03OSDiskName
    nTierApp03PrivateIpAddress: nTierApp03PrivateIpAddress
    nTierAppLoadBalancerName: nTierAppLoadBalancerName
    nTierAppLoadBalancerPrivateIpAddress: nTierAppLoadBalancerPrivateIpAddress
    nTierAppSubnetId: virtualNetwork002::nTierAppSubnet.id
    nTierWeb01Name: nTierWeb01Name
    nTierWeb01NICName: nTierWeb01NICName
    nTierWeb01OSDiskName: nTierWeb01OSDiskName
    nTierWeb01PrivateIpAddress: nTierWeb01PrivateIpAddress
    nTierWeb02Name: nTierWeb02Name
    nTierWeb02NICName: nTierWeb02NICName
    nTierWeb02OSDiskName: nTierWeb02OSDiskName
    nTierWeb02PrivateIpAddress: nTierWeb02PrivateIpAddress
    nTierWeb03Name: nTierWeb03Name
    nTierWeb03NICName: nTierWeb03NICName
    nTierWeb03OSDiskName: nTierWeb03OSDiskName
    nTierWeb03PrivateIpAddress: nTierWeb03PrivateIpAddress
    nTierWebSubnetId: virtualNetwork002::nTierWebSubnet.id
    proximityPlacementGroupAz1Name: proximityPlacementGroupAz1Name
    proximityPlacementGroupAz2Name: proximityPlacementGroupAz2Name
    proximityPlacementGroupAz3Name: proximityPlacementGroupAz3Name
  }
}

// Module - Vmss
//////////////////////////////////////////////////
module vmssModule 'azure_virtual_machines_vmss.bicep' = {
  scope: resourceGroup(vmssResourceGroupName)
  name: 'vmssDeployment'
  dependsOn: [
    vmssResourceGroup
  ]
  params: {
    adminPassword: keyVault.getSecret('resourcePassword')
    adminUserName: adminUserName
    logAnalyticsWorkspaceCustomerId: logAnalyticsWorkspace.properties.customerId
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    logAnalyticsWorkspaceKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
    vmssLoadBalancerName: vmssLoadBalancerName
    vmssLoadBalancerPublicIpAddressName: vmssLoadBalancerPublicIpAddressName
    vmssName: vmssName
    vmssNICName: vmssNICName
    vmssSubnetId: virtualNetwork002::vmssSubnet.id
  }
}

// Module - Windows 10 Client
//////////////////////////////////////////////////
module w10ClientModule './azure_virtual_machines_w10client.bicep' = {
  scope: resourceGroup(w10clientResourceGroupName)
  name: 'w10ClientDeployment'
  dependsOn: [
    w10clientResourceGroup
  ]
  params: {
    adminPassword: keyVault.getSecret('resourcePassword')
    adminUserName: adminUserName
    clientServicesSubnetId: virtualNetwork002::clientServicesSubnet.id
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    w10ClientName: w10ClientName
    w10ClientNICName: w10ClientNICName
    w10ClientOSDiskName: w10ClientOSDiskName
    w10ClientPrivateIpAddress: w10ClientPrivateIpAddress
  }
}
