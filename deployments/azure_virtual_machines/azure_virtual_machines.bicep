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

@description('The location for all resources.')
param location string = deployment().location

@description('The base URI for deployment scripts.')
param scriptsBaseUri string

// Global Variables
//////////////////////////////////////////////////
// Resource Groups
var adeAppVmResourceGroupName = 'rg-ade-${aliasRegion}-adeappvm'
var adeAppVmssResourceGroupName = 'rg-ade-${aliasRegion}-adeappvmss'
var jumpboxResourceGroupName = 'rg-ade-${aliasRegion}-jumpbox'
var keyVaultResourceGroupName = 'rg-ade-${aliasRegion}-keyvault'
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
var networkingResourceGroupName = 'rg-ade-${aliasRegion}-networking'
var proximityPlacementGroupResourceGroupName = 'rg-ade-${aliasRegion}-ppg'
// Resources
var adeAppVirtualMachines = [
  {
    name: adeAppVm01Name
    nicName: adeAppVm01NICName
    osDiskName: adeAppVm01OSDiskName
    availabilityZone: '1'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupAz1Id
  }
  {
    name: adeAppVm02Name
    nicName: adeAppVm02NICName
    osDiskName: adeAppVm02OSDiskName
    availabilityZone: '2'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupAz2Id
  }
  {
    name: adeAppVm03Name
    nicName: adeAppVm03NICName
    osDiskName: adeAppVm03OSDiskName
    availabilityZone: '3'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupAz3Id
  }
]
var adeAppVm01Name = 'vm-ade-${aliasRegion}-adeapp01'
var adeAppVm01NICName = 'nic-ade-${aliasRegion}-adeapp01'
var adeAppVm01OSDiskName = 'disk-ade-${aliasRegion}-adeapp01-os'
var adeAppVm02Name = 'vm-ade-${aliasRegion}-adeapp02'
var adeAppVm02NICName = 'nic-ade-${aliasRegion}-adeapp02'
var adeAppVm02OSDiskName = 'disk-ade-${aliasRegion}-adeapp02-os'
var adeAppVm03Name = 'vm-ade-${aliasRegion}-adeapp03'
var adeAppVm03NICName = 'nic-ade-${aliasRegion}-adeapp03'
var adeAppVm03OSDiskName = 'disk-ade-${aliasRegion}-adeapp03-os'
var adeAppVmLoadBalancerName = 'lbi-ade-${aliasRegion}-adeapp-vm'
var adeAppVmLoadBalancerPrivateIpAddress = '10.102.2.4'
var adeAppVmssLoadBalancerName = 'lbi-ade-${aliasRegion}-adeapp-vmss'
var adeAppVmssLoadBalancerPrivateIpAddress = '10.102.12.4'
var adeAppVmssName = 'vmss-ade-${aliasRegion}-adeapp-vmss'
var adeAppVmssNICName = 'nic-ade-${aliasRegion}-adeapp-vmss'
var adeAppVmssSubnetName = 'snet-ade-${aliasRegion}-adeapp-vmss'
var adeAppVmSubnetName = 'snet-ade-${aliasRegion}-adeapp-vm'
var adeWebVirtualMachines = [
  {
    name: adeWebVm01Name
    nicName: adeWebVm01NICName
    osDiskName: adeWebVm01OSDiskName
    availabilityZone: '1'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupAz1Id
  }
  {
    name: adeWebVm02Name
    nicName: adeWebVm02NICName
    osDiskName: adeWebVm02OSDiskName
    availabilityZone: '2'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupAz2Id
  }
  {
    name: adeWebVm03Name
    nicName: adeWebVm03NICName
    osDiskName: adeWebVm03OSDiskName
    availabilityZone: '3'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupAz3Id
  }
]
var adeWebVm01Name = 'vm-ade-${aliasRegion}-adeweb01'
var adeWebVm01NICName = 'nic-ade-${aliasRegion}-adeweb01'
var adeWebVm01OSDiskName = 'disk-ade-${aliasRegion}-adeweb01-os'
var adeWebVm02Name = 'vm-ade-${aliasRegion}-adeweb02'
var adeWebVm02NICName = 'nic-ade-${aliasRegion}-adeweb02'
var adeWebVm02OSDiskName = 'disk-ade-${aliasRegion}-adeweb02-os'
var adeWebVm03Name = 'vm-ade-${aliasRegion}-adeweb03'
var adeWebVm03NICName = 'nic-ade-${aliasRegion}-adeweb03'
var adeWebVm03OSDiskName = 'disk-ade-${aliasRegion}-adeweb03-os'
var adeWebVmssName = 'vmss-ade-${aliasRegion}-adeweb-vmss'
var adeWebVmssNICName = 'nic-ade-${aliasRegion}-adeweb-vmss'
var adeWebVmssSubnetName = 'snet-ade-${aliasRegion}-adeweb-vmss'
var adeWebVmSubnetName = 'snet-ade-${aliasRegion}-adeweb-vm'
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
var eventHubNamespaceAuthorizationRuleName = 'evh-ade-${aliasRegion}-diagnostics/RootManageSharedAccessKey'
var diagnosticsStorageAccountName = replace('sa-ade-${aliasRegion}-diags', '-', '')
var jumpboxName = 'vm-jumpbox01'
var jumpboxNICName = 'nic-ade-${aliasRegion}-jumpbox01'
var jumpboxOSDiskName = 'osdisk-ade-${aliasRegion}-jumpbox01'
var jumpboxPublicIpAddressName = 'pip-ade-${aliasRegion}-jumpbox01'
var keyVaultName = 'kv-ade-${aliasRegion}-001'
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
var managementSubnetName = 'snet-ade-${aliasRegion}-management'
var proximityPlacementGroupAz1Name = 'ppg-ade-${aliasRegion}-adeApp-az1'
var proximityPlacementGroupAz2Name = 'ppg-ade-${aliasRegion}-adeApp-az2'
var proximityPlacementGroupAz3Name = 'ppg-ade-${aliasRegion}-adeApp-az3'
var virtualNetwork001Name = 'vnet-ade-${aliasRegion}-001'
var virtualNetwork002Name = 'vnet-ade-${aliasRegion}-002'

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

// Existing Resource - Storage Account - Diagnostics
//////////////////////////////////////////////////
resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-01-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: diagnosticsStorageAccountName
}

// Existing Resource - Event Hub Authorization Rule
//////////////////////////////////////////////////
resource eventHubNamespaceAuthorizationRule 'Microsoft.EventHub/namespaces/authorizationRules@2021-11-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: eventHubNamespaceAuthorizationRuleName
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
  resource adeWebVmSubnet 'subnets@2020-07-01' existing = {
    name: adeWebVmSubnetName
  }
  resource adeAppVmSubnet 'subnets@2020-07-01' existing = {
    name: adeAppVmSubnetName
  }
  resource adeWebVmssSubnet 'subnets@2020-07-01' existing = {
    name: adeWebVmssSubnetName
  }
  resource adeAppVmssSubnet 'subnets@2020-07-01' existing = {
    name: adeAppVmssSubnetName
  }
}

// Resource Group - Jumpbox
//////////////////////////////////////////////////
resource jumpboxResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: jumpboxResourceGroupName
  location: azureRegion
}

// Resource Group - Proximity Placement Group
//////////////////////////////////////////////////
resource proximityPlacementGroupResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: proximityPlacementGroupResourceGroupName
  location: azureRegion
}

// Resource Group - ADE App Vm
//////////////////////////////////////////////////
resource adeAppVmResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: adeAppVmResourceGroupName
  location: azureRegion
}

// Resource Group - ADE App Vmss
//////////////////////////////////////////////////
resource adeAppVmssResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: adeAppVmssResourceGroupName
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
module proximityPlacementGroupModule 'azure_proximity_placement_groups_adeapp.bicep' = {
  scope: resourceGroup(proximityPlacementGroupResourceGroupName)
  name: 'proximityPlacementGroupDeployment'
  dependsOn: [
    proximityPlacementGroupResourceGroup
  ]
  params: {
    location: location
    proximityPlacementGroupAz1Name: proximityPlacementGroupAz1Name
    proximityPlacementGroupAz2Name: proximityPlacementGroupAz2Name
    proximityPlacementGroupAz3Name: proximityPlacementGroupAz3Name
  }
}

// Module - Load Balancer - ADE App Vm
//////////////////////////////////////////////////
module adeAppVmLoadBalancerModule 'azure_load_balancers_adeapp_vm.bicep' = {
  scope: resourceGroup(adeAppVmResourceGroupName)
  name: 'adeAppVmLoadBalancerDeployment'
  dependsOn: [
    adeAppVmResourceGroup
  ]
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
  scope: resourceGroup(adeAppVmssResourceGroupName)
  name: 'adeAppVmssLoadBalancerDeployment'
  dependsOn: [
    adeAppVmssResourceGroup
  ]
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
  scope: resourceGroup(adeAppVmResourceGroupName)
  name: 'adeWebVmDeployment'
  dependsOn: [
    adeAppVmResourceGroup
  ]
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
  scope: resourceGroup(adeAppVmResourceGroupName)
  name: 'adeAppVmDeployment'
  dependsOn: [
    adeAppVmResourceGroup
  ]
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
  scope: resourceGroup(adeAppVmssResourceGroupName)
  name: 'adeWebVmssDeployment'
  dependsOn: [
    adeAppVmssResourceGroup
  ]
  params: {
    adeWebVmssName: adeWebVmssName
    adeWebVmssNICName: adeWebVmssNICName
    adeWebVmssSubnetId: virtualNetwork002::adeWebVmssSubnet.id
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
  scope: resourceGroup(adeAppVmssResourceGroupName)
  name: 'adeAppVmssDeployment'
  dependsOn: [
    adeAppVmssResourceGroup
  ]
  params: {
    adeAppVmssLoadBalancerBackendPoolId: adeAppVmssLoadBalancerModule.outputs.adeAppVmssLoadBalancerBackendPoolId
    adeAppVmssName: adeAppVmssName
    adeAppVmssNICName: adeAppVmssNICName
    adeAppVmssSubnetId: virtualNetwork002::adeAppVmssSubnet.id
    adminPassword: keyVault.getSecret('resourcePassword')
    adminUserName: adminUserName
    location: location
    logAnalyticsWorkspaceCustomerId: logAnalyticsWorkspace.properties.customerId
    logAnalyticsWorkspaceKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
  }
}
