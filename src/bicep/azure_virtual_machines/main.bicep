// Parameters
//////////////////////////////////////////////////
@description('The name of the admin user.')
param adminUserName string

@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('The current date.')
param currentDate string = utcNow('yyyy-MM-dd')

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of the Management Resource Group.')
param managementResourceGroupName string

@description('The name of the Networking Resource Group.')
param networkingResourceGroupName string

@description('The name of the owner of the deployment.')
param ownerName string

@description('The name of the Security Resource Group.')
param securityResourceGroupName string

// Variables
//////////////////////////////////////////////////
var tags = {
  deploymentDate: currentDate
  owner: ownerName
}

// Variables - Proximity Placement Group
//////////////////////////////////////////////////
var proximityPlacementGroups = [
  {
    name: 'ppg-${appEnvironment}-adeApp-az1'
    proximityPlacementGroupType: 'Standard'
  }
  {
    name: 'ppg-${appEnvironment}-adeApp-az2'
  }
  {
    name: 'ppg-${appEnvironment}-adeApp-az3'
  }
]

// Variables - Load Balancer
//////////////////////////////////////////////////

// Variable Arrays
//////////////////////////////////////////////////
var loadBalancers = [
  {
    name: 'lbi-${appEnvironment}-adeapp-vm'
    sku: {
      name: 'Standard'
    }
    properties: {
      frontendIPConfigurations: [
        {
          name: 'fip-lbi-${appEnvironment}-adeapp-vm'
          properties: {
            subnet: {
              id: spokeVirtualNetwork::adeAppVmSubnet.id
            }
            privateIpAddress: '10.102.2.4'
            privateIPAllocationMethod: 'Static'
          }
        }
      ]
      backendAddressPools: [
        {
          name: 'bep-lbi-${appEnvironment}-adeapp-vm'
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
              id: spokeVirtualNetwork::adeAppVmssSubnet.id
            }
            privateIpAddress: '10.102.12.4'
            privateIPAllocationMethod: 'Static'
          }
        }
      ]
      backendAddressPools: [
        {
          name: 'bep-lbi-${appEnvironment}-adeapp-vmss'
        }
      ]
    }    
  }
]
var loadBalancerBackendServices = [
  {
    probeName: 'probe-DataIngestorService'
    protocol: 'Http'
    requestPath: '/swagger/index.html'
    port: 5000
    intervalInSeconds: 15
    numberOfProbes: 2
  }
  {
    probeName: 'probe-DataReporterService'
    protocol: 'Http'
    requestPath: '/swagger/index.html'
    port: 5001
    intervalInSeconds: 15
    numberOfProbes: 2
  }
  {
    probeName: 'probe-UserService'
    protocol: 'Http'
    requestPath: '/swagger/index.html'
    port: 5002
    intervalInSeconds: 15
    numberOfProbes: 2
  }
  {
    probeName: 'probe-EventIngestorService'
    protocol: 'Http'
    requestPath: '/swagger/index.html'
    port: 5003
    intervalInSeconds: 15
    numberOfProbes: 2
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
    subnetId: spokeVirtualNetwork::adeAppVmSubnet.id
  }
  {
    name: 'vm-${appEnvironment}-adeapp02'
    availabilityZone: '2'
    loadBalancerBackendPoolId: loadBalancerModule.outputs.loadBalancerProperties[0].resourceId
    nicName: 'nic-${appEnvironment}-adeapp02'
    osDiskName: 'disk-${appEnvironment}-adeapp02-os'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupProperties[1].resourceId
    subnetId: spokeVirtualNetwork::adeAppVmSubnet.id
  }
  {
    name: 'vm-${appEnvironment}-adeapp03'
    availabilityZone: '3'
    loadBalancerBackendPoolId: loadBalancerModule.outputs.loadBalancerProperties[0].resourceId
    nicName: 'nic-${appEnvironment}-adeapp03'
    osDiskName: 'disk-${appEnvironment}-adeapp03-os'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupProperties[2].resourceId
    subnetId: spokeVirtualNetwork::adeAppVmSubnet.id
  }
  {
    name: 'vm-${appEnvironment}-adeweb01'
    availabilityZone: '1'
    loadBalancerBackendPoolId: null
    nicName: 'nic-${appEnvironment}-adeweb01'
    osDiskName: 'disk-${appEnvironment}-adeweb01-os'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupProperties[0].resourceId
    subnetId: spokeVirtualNetwork::adeWebVmSubnet.id
  }
  {
    name: 'vm-${appEnvironment}-adeweb02'
    availabilityZone: '2'
    loadBalancerBackendPoolId: null
    nicName: 'nic-${appEnvironment}-adeweb02'
    osDiskName: 'disk-${appEnvironment}-adeweb02-os'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupProperties[1].resourceId
    subnetId: spokeVirtualNetwork::adeWebVmSubnet.id
  }
  {
    name: 'vm-${appEnvironment}-adeweb03'
    availabilityZone: '3'
    loadBalancerBackendPoolId: null
    nicName: 'nic-${appEnvironment}-adeweb03'
    osDiskName: 'disk-${appEnvironment}-adeweb03-os'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.proximityPlacementGroupProperties[2].resourceId
    subnetId: spokeVirtualNetwork::adeWebVmSubnet.id
  }
]

var virtualMachineScaleSets = [
  {
    name: 'vmss-${appEnvironment}-adeapp-vmss'
    nicName: 'nic-${appEnvironment}-adeapp-vmss'
    subnetId: spokeVirtualNetwork::adeAppVmssSubnet.id
    loadBalancerBackendPoolId: loadBalancerModule.outputs.loadBalancerProperties[1].resourceId
  }
  {
    name: 'vmss-${appEnvironment}-adeweb-vmss'
    nicName: 'nic-${appEnvironment}-adeweb-vmss'
    subnetId: spokeVirtualNetwork::adeWebVmssSubnet.id
    loadBalancerBackendPoolId: null
  }
]

// Variables - Existing Resources
//////////////////////////////////////////////////
var adeAppVmssSubnetName = 'snet-${appEnvironment}-adeApp-vmss'
var adeAppVmSubnetName = 'snet-${appEnvironment}-adeApp-vm'
var adeWebVmssSubnetName = 'snet-${appEnvironment}-adeWeb-vmss'
var adeWebVmSubnetName = 'snet-${appEnvironment}-adeWeb-vm'
var eventHubNamespaceAuthorizationRuleName = 'RootManageSharedAccessKey'
var eventHubNamespaceName = 'evhns-${appEnvironment}-diagnostics'
var keyVaultName = 'kv-${appEnvironment}'
var logAnalyticsWorkspaceName = 'log-${appEnvironment}'
var spokeVirtualNetworkName = 'vnet-${appEnvironment}-spoke'
var storageAccountName = replace('sa-diag-${uniqueString(subscription().subscriptionId)}', '-', '')

// Existing Resource - Event Hub Authorization Rule
//////////////////////////////////////////////////
resource eventHubNamespaceAuthorizationRule 'Microsoft.EventHub/namespaces/authorizationRules@2022-10-01-preview' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: '${eventHubNamespaceName}/${eventHubNamespaceAuthorizationRuleName}'
}

// Existing Resource - Key Vault
//////////////////////////////////////////////////
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  scope: resourceGroup(securityResourceGroupName)
  name: keyVaultName
}

// Existing Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: logAnalyticsWorkspaceName
}

// Existing Resource - Storage Account - Diagnostics
//////////////////////////////////////////////////
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: storageAccountName
}

// Existing Resource - Virtual Network - Spoke
//////////////////////////////////////////////////
resource spokeVirtualNetwork 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: spokeVirtualNetworkName
  resource adeAppVmssSubnet 'subnets@2022-09-01' existing = {
    name: adeAppVmssSubnetName
  }
  resource adeAppVmSubnet 'subnets@2022-09-01' existing = {
    name: adeAppVmSubnetName
  }
  resource adeWebVmssSubnet 'subnets@2022-09-01' existing = {
    name: adeWebVmssSubnetName
  }
  resource adeWebVmSubnet 'subnets@2022-09-01' existing = {
    name: adeWebVmSubnetName
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
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    loadBalancerBackendServices: loadBalancerBackendServices
    loadBalancers: loadBalancers
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    storageAccountId: storageAccount.id
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
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location: location
    logAnalyticsWorkspaceCustomerId: logAnalyticsWorkspace.properties.customerId
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    logAnalyticsWorkspaceKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey 
    storageAccountId: storageAccount.id
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
