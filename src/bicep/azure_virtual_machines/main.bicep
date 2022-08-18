// Parameters
//////////////////////////////////////////////////
@description('The name of the admin user.')
param adminUserName string

@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('The date of the resource deployment.')
param deploymentDate string = utcNow('yyyy-MM-dd')

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of the Management Resource Group.')
param managementResourceGroupName string

@description('The name of the Networking Resource Group.')
param networkingResourceGroupName string

@description('The name of the owner of the deployment.')
param ownerName string

@description('The base URI for deployment scripts.')
param scriptsBaseUri string

@description('The name of the Security Resource Group.')
param securityResourceGroupName string

// Variables
//////////////////////////////////////////////////
var jumpboxName = 'vm-jumpbox01'
var jumpboxNICName = 'nic-${appEnvironment}-jumpbox01'
var jumpboxOSDiskName = 'osdisk-${appEnvironment}-jumpbox01'
var jumpboxPublicIpAddressName = 'pip-${appEnvironment}-jumpbox01'
var tags = {
  deploymentDate: deploymentDate
  owner: ownerName
}

// Variable Arrays
//////////////////////////////////////////////////
var adeLoadBalancers = [
  {
    name: 'lbi-${appEnvironment}-adeapp-vm'
    privateIpAddress: '10.102.2.4'
  }
  {
    name: 'lbi-${appEnvironment}-adeapp-vmss'
    privateIpAddress: '10.102.12.4'
  }
]

var backendServices = [
  {
    name: 'DataIngestorService'
    port: 5000
  }
  {
    name: 'DataReporterService'
    port: 5001
  }
  {
    name: 'UserService'
    port: 5002
  }
  {
    name: 'EventIngestorService'
    port: 5003
  }
]

var adeVirtualMachines = [
  {
    name: 'vm-${appEnvironment}-adeapp01'
    nicName: 'nic-${appEnvironment}-adeapp01'
    osDiskName: 'disk-${appEnvironment}-adeapp01-os'
    availabilityZone: '1'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupProperties[0].resourceId
    subnetId: virtualNetwork002::adeAppVmSubnet.id
  }
  {
    name: 'vm-${appEnvironment}-adeapp02'
    nicName: 'nic-${appEnvironment}-adeapp02'
    osDiskName: 'disk-${appEnvironment}-adeapp02-os'
    availabilityZone: '2'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupProperties[1].resourceId
    subnetId: virtualNetwork002::adeAppVmSubnet.id
  }
  {
    name: 'vm-${appEnvironment}-adeapp03'
    nicName: 'nic-${appEnvironment}-adeapp03'
    osDiskName: 'disk-${appEnvironment}-adeapp03-os'
    availabilityZone: '3'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupProperties[2].resourceId
    subnetId: virtualNetwork002::adeAppVmSubnet.id
  }
  {
    name: 'vm-${appEnvironment}-adeweb01'
    nicName: 'nic-${appEnvironment}-adeweb01'
    osDiskName: 'disk-${appEnvironment}-adeweb01-os'
    availabilityZone: '1'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupProperties[0].resourceId
    subnetId: virtualNetwork002::adeWebVmSubnet.id
  }
  {
    name: 'vm-${appEnvironment}-adeweb02'
    nicName: 'nic-${appEnvironment}-adeweb02'
    osDiskName: 'disk-${appEnvironment}-adeweb02-os'
    availabilityZone: '2'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupProperties[1].resourceId
    subnetId: virtualNetwork002::adeWebVmSubnet.id
  }
  {
    name: 'vm-${appEnvironment}-adeweb03'
    nicName: 'nic-${appEnvironment}-adeweb03'
    osDiskName: 'disk-${appEnvironment}-adeweb03-os'
    availabilityZone: '3'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupProperties[2].resourceId
    subnetId: virtualNetwork002::adeWebVmSubnet.id
  }
]
var adeVirtualMachineScaleSets = [
  {
    name: 'vmss-${appEnvironment}-adeapp-vmss'
    nicName: 'nic-${appEnvironment}-adeapp-vmss'
    subnetId: virtualNetwork002::adeAppVmssSubnet.id
  }
  {
    name: 'vmss-${appEnvironment}-adeweb-vmss'
    nicName: 'nic-${appEnvironment}-adeweb-vmss'
    subnetId: virtualNetwork002::adeWebVmssSubnet.id
    adeAppVmssLoadBalancerBackendPoolId: adeAppVmssLoadBalancerModule.outputs.adeAppVmssLoadBalancerBackendPoolId
  }
]






// var adeAppVirtualMachines = [
//   {
//     name: 'vm-${appEnvironment}-adeapp01'
//     nicName: 'nic-${appEnvironment}-adeapp01'
//     osDiskName: 'disk-${appEnvironment}-adeapp01-os'
//     availabilityZone: '1'
//     proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupProperties[0].resourceId
//   }
//   {
//     name: 'vm-${appEnvironment}-adeapp02'
//     nicName: 'nic-${appEnvironment}-adeapp02'
//     osDiskName: 'disk-${appEnvironment}-adeapp02-os'
//     availabilityZone: '2'
//     proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupProperties[1].resourceId
//   }
//   {
//     name: 'vm-${appEnvironment}-adeapp03'
//     nicName: 'nic-${appEnvironment}-adeapp03'
//     osDiskName: 'disk-${appEnvironment}-adeapp03-os'
//     availabilityZone: '3'
//     proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupProperties[2].resourceId
//   }
// ]
// var adeWebVirtualMachines = [
//   {
//     name: 'vm-${appEnvironment}-adeweb01'
//     nicName: 'nic-${appEnvironment}-adeweb01'
//     osDiskName: 'disk-${appEnvironment}-adeweb01-os'
//     availabilityZone: '1'
//     proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupProperties[0].resourceId
//   }
//   {
//     name: 'vm-${appEnvironment}-adeweb02'
//     nicName: 'nic-${appEnvironment}-adeweb02'
//     osDiskName: 'disk-${appEnvironment}-adeweb02-os'
//     availabilityZone: '2'
//     proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupProperties[1].resourceId
//   }
//   {
//     name: 'vm-${appEnvironment}-adeweb03'
//     nicName: 'nic-${appEnvironment}-adeweb03'
//     osDiskName: 'disk-${appEnvironment}-adeweb03-os'
//     availabilityZone: '3'
//     proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupProperties[2].resourceId
//   }
// ]


var proximityPlacementGroups = [
  {
    name: 'ppg-${appEnvironment}-adeApp-az1'
  }
  {
    name: 'ppg-${appEnvironment}-adeApp-az2'
  }
  {
    name: 'ppg-${appEnvironment}-adeApp-az3'
  }
]

// Existing Resource - Event Hub Authorization Rule
//////////////////////////////////////////////////
resource eventHubNamespaceAuthorizationRule 'Microsoft.EventHub/namespaces/authorizationRules@2021-11-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: 'evh-${appEnvironment}-diagnostics/RootManageSharedAccessKey'
}

// Existing Resource - Key Vault
//////////////////////////////////////////////////
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  scope: resourceGroup(securityResourceGroupName)
  name: 'kv-${appEnvironment}-001'
}

// Existing Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: 'log-${appEnvironment}-001'
}

// Existing Resource - Storage Account - Diagnostics
//////////////////////////////////////////////////
resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: replace('sa-${appEnvironment}-diags', '-', '')
}

// Existing Resource - Virtual Network - Virtual Network 001
//////////////////////////////////////////////////
resource virtualNetwork001 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'vnet-${appEnvironment}-001'
  resource managementSubnet 'subnets@2020-07-01' existing = {
    name: 'snet-${appEnvironment}-management'
  }
}

// Existing Resource - Virtual Network - Virtual Network 002
//////////////////////////////////////////////////
resource virtualNetwork002 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'vnet-${appEnvironment}-002'
  resource adeAppVmssSubnet 'subnets@2020-07-01' existing = {
    name: 'snet-${appEnvironment}-adeapp-vmss'
  }
  resource adeAppVmSubnet 'subnets@2020-07-01' existing = {
    name: 'snet-${appEnvironment}-adeapp-vm'
  }
  resource adeWebVmssSubnet 'subnets@2020-07-01' existing = {
    name: 'snet-${appEnvironment}-adeweb-vmss'
  }
  resource adeWebVmSubnet 'subnets@2020-07-01' existing = {
    name: 'snet-${appEnvironment}-adeweb-vm'
  }  
}

// Module - Jumpbox
//////////////////////////////////////////////////
module jumpBoxModule './azure_virtual_machines_jumpbox.bicep' = {
  name: 'jumpBoxDeployment'
  params: {
    adminPassword: keyVault.getSecret('resourcePassword')
    adminUserName: adminUserName
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    jumpboxName: jumpboxName
    jumpboxNICName: jumpboxNICName
    jumpboxOSDiskName: jumpboxOSDiskName
    jumpboxPublicIpAddressName: jumpboxPublicIpAddressName
    location: location
    logAnalyticsWorkspaceCustomerId: logAnalyticsWorkspace.properties.customerId
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    logAnalyticsWorkspaceKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
    managementSubnetId: virtualNetwork001::managementSubnet.id
    scriptsBaseUri: scriptsBaseUri
  }
}

// Module - Proximity Placement Group
//////////////////////////////////////////////////
module proximityPlacementGroupModule 'proximity_placement_group.bicep' = {
  name: 'proximityPlacementGroupDeployment'
  params: {
    location: location
    proximityPlacementGroups: proximityPlacementGroups
    tags: tags
  }
}

// Module - Load Balancer - ADE App Vm
//////////////////////////////////////////////////
module adeAppVmLoadBalancerModule 'azure_load_balancers_adeapp_vm.bicep' = {
  name: 'adeAppVmLoadBalancerDeployment'
  params: {
    adeAppVmLoadBalancerName: adeAppVmLoadBalancerName
    adeAppVmLoadBalancerPrivateIpAddress: adeAppVmLoadBalancerPrivateIpAddress
    adeAppVmSubnetId: virtualNetwork002::adeAppVmSubnet.id
    backendServices: backendServices
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
  }
}

// Module - Load Balancer - ADE App Vmss
//////////////////////////////////////////////////
module adeAppVmssLoadBalancerModule 'azure_load_balancers_adeapp_vmss.bicep' = {
  name: 'adeAppVmssLoadBalancerDeployment'
  params: {
    adeAppVmssLoadBalancerName: adeAppVmssLoadBalancerName
    adeAppVmssLoadBalancerPrivateIpAddress: adeAppVmssLoadBalancerPrivateIpAddress
    adeAppVmssSubnetId: virtualNetwork002::adeAppVmssSubnet.id
    backendServices: backendServices
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
  }
}

// Module - ADE Web Vm
//////////////////////////////////////////////////
module adeWebVmModule 'azure_virtual_machines_adeweb_vm.bicep' = {
  name: 'adeWebVmDeployment'
  params: {
    adeWebVirtualMachines: adeWebVirtualMachines
    adeWebVmSubnetId: virtualNetwork002::adeWebVmSubnet.id
    adminPassword: keyVault.getSecret('resourcePassword')
    adminUserName: adminUserName
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location: location
    logAnalyticsWorkspaceCustomerId: logAnalyticsWorkspace.properties.customerId
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    logAnalyticsWorkspaceKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
  }
}

// Module - ADE App Vm
//////////////////////////////////////////////////
module adeAppVmModule 'azure_virtual_machines_adeapp_vm.bicep' = {
  name: 'adeAppVmDeployment'
  params: {
    adeAppVirtualMachines: adeAppVirtualMachines
    adeAppVmLoadBalancerBackendPoolId: adeAppVmLoadBalancerModule.outputs.adeAppVmLoadBalancerBackendPoolId
    adeAppVmSubnetId: virtualNetwork002::adeAppVmSubnet.id
    adminPassword: keyVault.getSecret('resourcePassword')
    adminUserName: adminUserName
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location: location
    logAnalyticsWorkspaceCustomerId: logAnalyticsWorkspace.properties.customerId
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    logAnalyticsWorkspaceKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
  }
}

// Module - ADE Web Vmss
//////////////////////////////////////////////////
module adeWebVmssModule 'azure_virtual_machines_adeweb_vmss.bicep' = {
  name: 'adeWebVmssDeployment'
  params: {
    adminPassword: keyVault.getSecret('resourcePassword')
    adminUserName: adminUserName
    location: location
    logAnalyticsWorkspaceCustomerId: logAnalyticsWorkspace.properties.customerId
    logAnalyticsWorkspaceKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
  }
}

// Module - ADE App Vmss
//////////////////////////////////////////////////
module adeAppVmssModule 'azure_virtual_machines_adeapp_vmss.bicep' = {
  name: 'adeAppVmssDeployment'
  params: {
    adminPassword: keyVault.getSecret('resourcePassword')
    adminUserName: adminUserName
    location: location
    logAnalyticsWorkspaceCustomerId: logAnalyticsWorkspace.properties.customerId
    logAnalyticsWorkspaceKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
  }
}
