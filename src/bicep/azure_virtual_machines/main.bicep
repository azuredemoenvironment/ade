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
var loadBalancers = [
  {
    name: 'lbi-${appEnvironment}-adeapp-vm'
    properties: {
      frontendIPConfigurations: [
        {
          name: 'fip-lbi-${appEnvironment}-adeapp-vm'
          properties: {
            subnet: {
              id: virtualNetwork002::adeAppVmSubnet.id
            }
            privateIpAddress: '10.102.2.4'
            privateIPAllocationMethod: 'Static'
          }
        }
      ]
    }    
  }
  {
    name: 'lbi-${appEnvironment}-adeapp-vmss'
    properties: {
      frontendIPConfigurations: [
        {
          name: 'fip-lbi-${appEnvironment}-adeapp-vmss'
          properties: {
            subnet: {
              id: virtualNetwork002::adeAppVmssSubnet.id
            }
            privateIpAddress: '10.102.12.4'
            privateIPAllocationMethod: 'Static'
          }
        }
      ]
    }    
  }
]
var loadBalancerBackendServices = [
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
var virtualMachines = [
  {
    name: 'vm-${appEnvironment}-adeapp01'
    availabilityZone: '1'
    loadBalancerBackendPoolId: loadBalancerModule.outputs.loadBalancerProperties[0].resourceId
    nicName: 'nic-${appEnvironment}-adeapp01'
    osDiskName: 'disk-${appEnvironment}-adeapp01-os'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupProperties[0].resourceId
    subnetId: virtualNetwork002::adeAppVmSubnet.id
  }
  {
    name: 'vm-${appEnvironment}-adeapp02'
    availabilityZone: '2'
    loadBalancerBackendPoolId: loadBalancerModule.outputs.loadBalancerProperties[0].resourceId
    nicName: 'nic-${appEnvironment}-adeapp02'
    osDiskName: 'disk-${appEnvironment}-adeapp02-os'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupProperties[1].resourceId
    subnetId: virtualNetwork002::adeAppVmSubnet.id
  }
  {
    name: 'vm-${appEnvironment}-adeapp03'
    availabilityZone: '3'
    loadBalancerBackendPoolId: loadBalancerModule.outputs.loadBalancerProperties[0].resourceId
    nicName: 'nic-${appEnvironment}-adeapp03'
    osDiskName: 'disk-${appEnvironment}-adeapp03-os'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupProperties[2].resourceId
    subnetId: virtualNetwork002::adeAppVmSubnet.id
  }
  {
    name: 'vm-${appEnvironment}-adeweb01'
    availabilityZone: '1'
    loadBalancerBackendPoolId: null
    nicName: 'nic-${appEnvironment}-adeweb01'
    osDiskName: 'disk-${appEnvironment}-adeweb01-os'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupProperties[0].resourceId
    subnetId: virtualNetwork002::adeWebVmSubnet.id
  }
  {
    name: 'vm-${appEnvironment}-adeweb02'
    availabilityZone: '2'
    loadBalancerBackendPoolId: null
    nicName: 'nic-${appEnvironment}-adeweb02'
    osDiskName: 'disk-${appEnvironment}-adeweb02-os'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupProperties[1].resourceId
    subnetId: virtualNetwork002::adeWebVmSubnet.id
  }
  {
    name: 'vm-${appEnvironment}-adeweb03'
    availabilityZone: '3'
    loadBalancerBackendPoolId: null
    nicName: 'nic-${appEnvironment}-adeweb03'
    osDiskName: 'disk-${appEnvironment}-adeweb03-os'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupProperties[2].resourceId
    subnetId: virtualNetwork002::adeWebVmSubnet.id
  }
]
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
var virtualMachineScaleSets = [
  {
    name: 'vmss-${appEnvironment}-adeapp-vmss'
    nicName: 'nic-${appEnvironment}-adeapp-vmss'
    subnetId: virtualNetwork002::adeAppVmssSubnet.id
    loadBalancerBackendPoolId: loadBalancerModule.outputs.loadBalancerProperties[1].resourceId
  }
  {
    name: 'vmss-${appEnvironment}-adeweb-vmss'
    nicName: 'nic-${appEnvironment}-adeweb-vmss'
    subnetId: virtualNetwork002::adeWebVmssSubnet.id
    loadBalancerBackendPoolId: null
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

// Module - Load Balancer
//////////////////////////////////////////////////
module loadBalancerModule 'load_balancer.bicep' = {
  name: 'loadBalancerDeployment'
  params: {
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    loadBalancerBackendServices: loadBalancerBackendServices
    loadBalancers: loadBalancers
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    tags: tags
  }
}

// Module - Virtual Machine
//////////////////////////////////////////////////
module virtualMachineModule 'virtual_machine.bicep' = {
  name: 'virtualMachineDeployment'
  params: {
    adminPassword: keyVault.getSecret('resourcePassword')
    adminUserName: adminUserName
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location: location
    logAnalyticsWorkspaceCustomerId: logAnalyticsWorkspace.properties.customerId
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    logAnalyticsWorkspaceKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey 
    tags: tags
    virtualMachines: virtualMachines
  }
}

// Module - Virtual Machine Scale Set
//////////////////////////////////////////////////
module virtualMachineScaleSetModule 'virtual_machine_scale_set.bicep' = {
  name: 'virtualMachineScaleSetDeployment'
  params: {
    adminPassword: keyVault.getSecret('resourcePassword')
    adminUserName: adminUserName
    location: location
    logAnalyticsWorkspaceCustomerId: logAnalyticsWorkspace.properties.customerId
    logAnalyticsWorkspaceKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
    tags: tags
    virtualMachineScaleSets: virtualMachineScaleSets
  }
}
