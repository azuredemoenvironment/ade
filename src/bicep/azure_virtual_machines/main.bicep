// Parameters
//////////////////////////////////////////////////
@description('The name of the admin user.')
param adminUserName string

@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('The current date.')
param currentDate string = utcNow('yyyy-MM-dd')

@description('The name of the Dns Zone Resource Group.')
param dnsZoneResourceGroupName string

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of the Management Resource Group.')
param managementResourceGroupName string

@description('The name of the Networking Resource Group.')
param networkingResourceGroupName string

@description('The name of the owner of the deployment.')
param ownerName string

@description('The value for Root Domain Name.')
param rootDomainName string

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
    proximityPlacementGroupType: 'Standard'
  }
  {
    name: 'ppg-${appEnvironment}-adeApp-az3'
    proximityPlacementGroupType: 'Standard'
  }
]

// Variables - Load Balancer
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
          name: 'frontendIPConfiguration'
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
          name: 'backendAddressPool'
        }
      ]
    }    
  }
  {
    name: 'lbi-${appEnvironment}-adeapp-vmss'
    sku: {
      name: 'Standard'
    }
    properties: {
      frontendIPConfigurations: [
        {
          name: 'frontendIPConfiguration'
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
          name: 'backendAddressPool'
        }
      ]
    }    
  }
]
var loadBalancerServices = [
  {
    probeName: 'probe-DataIngestorService'
    probeProtocol: 'Http'
    requestPath: '/swagger/index.html'
    port: 5000
    intervalInSeconds: 15
    numberOfProbes: 2
    loadBalancingRuleName: 'lbr-DataIngestorService'
    loadBalancingRuleProtocol: 'Tcp'
    idleTimeoutInMinutes: 15
  }
  {
    probeName: 'probe-DataReporterService'
    probeProtocol: 'Http'
    requestPath: '/swagger/index.html'
    port: 5001
    intervalInSeconds: 15
    numberOfProbes: 2
    loadBalancingRuleName: 'lbr-DataReporterService'
    loadBalancingRuleProtocol: 'Tcp'
    idleTimeoutInMinutes: 15
  }
  {
    probeName: 'probe-UserService'
    probeProtocol: 'Http'
    requestPath: '/swagger/index.html'
    port: 5002
    intervalInSeconds: 15
    numberOfProbes: 2
    loadBalancingRuleName: 'lbr-UserService'
    loadBalancingRuleProtocol: 'Tcp'
    idleTimeoutInMinutes: 15
  }
  {
    probeName: 'probe-EventIngestorService'
    probeProtocol: 'Http'
    requestPath: '/swagger/index.html'
    port: 5003
    intervalInSeconds: 15
    numberOfProbes: 2
    loadBalancingRuleName: 'lbr-EventIngestorService'
    loadBalancingRuleProtocol: 'Tcp'
    idleTimeoutInMinutes: 15
  }
]

// Variables - Virtual Machine - Image Reference
//////////////////////////////////////////////////
var virtualMachineImageReference = {
  publisher: 'Canonical'
  offer: 'UbuntuServer'
  sku: '20.04-LTS'
  version: 'latest'
}

// Variables - Virtual Machine
//////////////////////////////////////////////////
var virtualMachines = [
  {
    nicName: 'nic-${appEnvironment}-adeapp01'
    privateIPAllocationMethod: 'Dynamic'
    subnetId: spokeVirtualNetwork::adeAppVmSubnet.id
    loadBalancerBackendPoolId: loadBalancerModule.outputs.loadBalancerProperties[0].resourceId
    applicationGatewayBackendPoolIds: null
    name: 'vm-${appEnvironment}-adeapp01'
    availabilityZone: '1'
    identityType: 'SystemAssigned'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.ppgProperties[0].resourceId
    vmSize: 'Standard_B1s'
    imageReference: virtualMachineImageReference
    osType: 'Linux'
    osDiskName: 'disk-${appEnvironment}-adeapp01-os'
    createOption: 'FromImage'
    storageAccountType: 'Standard_LRS'
    managedIdentityId: virtualMachineManagedIdentity.properties.principalId
    dataCollectionRuleId: dataCollectionRule.id
  }
  {
    nicName: 'nic-${appEnvironment}-adeapp02'
    privateIPAllocationMethod: 'Dynamic'
    subnetId: spokeVirtualNetwork::adeAppVmSubnet.id
    loadBalancerBackendPoolId: loadBalancerModule.outputs.loadBalancerProperties[0].resourceId
    applicationGatewayBackendPoolIds: null
    name: 'vm-${appEnvironment}-adeapp02'
    availabilityZone: '2'
    identityType: 'SystemAssigned'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.ppgProperties[1].resourceId
    vmSize: 'Standard_B1s'
    imageReference: virtualMachineImageReference
    osType: 'Linux'
    osDiskName: 'disk-${appEnvironment}-adeapp02-os'
    createOption: 'FromImage'
    storageAccountType: 'Standard_LRS'
    managedIdentityId: virtualMachineManagedIdentity.properties.principalId
    dataCollectionRuleId: dataCollectionRule.id
  }
  {
    nicName: 'nic-${appEnvironment}-adeapp03'
    privateIPAllocationMethod: 'Dynamic'
    subnetId: spokeVirtualNetwork::adeAppVmSubnet.id
    loadBalancerBackendPoolId: loadBalancerModule.outputs.loadBalancerProperties[0].resourceId
    applicationGatewayBackendPoolIds: null
    name: 'vm-${appEnvironment}-adeapp03'
    availabilityZone: '3'
    identityType: 'SystemAssigned'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.ppgProperties[2].resourceId
    vmSize: 'Standard_B1s'
    imageReference: virtualMachineImageReference
    osType: 'Linux'
    osDiskName: 'disk-${appEnvironment}-adeapp03-os'
    createOption: 'FromImage'
    storageAccountType: 'Standard_LRS'
    managedIdentityId: virtualMachineManagedIdentity.properties.principalId
    dataCollectionRuleId: dataCollectionRule.id
  }
  {
    nicName: 'nic-${appEnvironment}-adeweb01'
    privateIPAllocationMethod: 'Dynamic'
    subnetId: spokeVirtualNetwork::adeWebVmSubnet.id
    loadBalancerBackendPoolId: null
    applicationGatewayBackendPoolIds: [
      {
        id: resourceId(networkingResourceGroupName, 'Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, applicationGatewayAdeAppFrontendVmBackendPoolName)
      }
      {
        id: resourceId(networkingResourceGroupName,'Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, applicationGatewayAdeAppApiGatewayVmBackendPoolName)
      }
    ]
    name: 'vm-${appEnvironment}-adeweb01'
    availabilityZone: '1'
    identityType: 'SystemAssigned'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.ppgProperties[0].resourceId
    vmSize: 'Standard_B1s'
    imageReference: virtualMachineImageReference
    osType: 'Linux'
    osDiskName: 'disk-${appEnvironment}-adeweb01-os'
    createOption: 'FromImage'
    storageAccountType: 'Standard_LRS'
    managedIdentityId: virtualMachineManagedIdentity.properties.principalId
    dataCollectionRuleId: dataCollectionRule.id
  }
  {
    nicName: 'nic-${appEnvironment}-adeweb02'
    privateIPAllocationMethod: 'Dynamic'
    subnetId: spokeVirtualNetwork::adeWebVmSubnet.id
    loadBalancerBackendPoolId: null
    applicationGatewayBackendPoolIds: [
      {
        id: resourceId(networkingResourceGroupName, 'Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, applicationGatewayAdeAppFrontendVmBackendPoolName)
      }
      {
        id: resourceId(networkingResourceGroupName,'Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, applicationGatewayAdeAppApiGatewayVmBackendPoolName)
      }
    ]
    name: 'vm-${appEnvironment}-adeweb02'
    availabilityZone: '2'
    identityType: 'SystemAssigned'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.ppgProperties[1].resourceId
    vmSize: 'Standard_B1s'
    imageReference: virtualMachineImageReference
    osType: 'Linux'
    osDiskName: 'disk-${appEnvironment}-adeweb02-os'
    createOption: 'FromImage'
    storageAccountType: 'Standard_LRS'
    managedIdentityId: virtualMachineManagedIdentity.properties.principalId
    dataCollectionRuleId: dataCollectionRule.id
  }
  {
    nicName: 'nic-${appEnvironment}-adeweb03'
    privateIPAllocationMethod: 'Dynamic'
    subnetId: spokeVirtualNetwork::adeWebVmSubnet.id
    loadBalancerBackendPoolId: null
    applicationGatewayBackendPoolIds: [
      {
        id: resourceId(networkingResourceGroupName, 'Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, applicationGatewayAdeAppFrontendVmBackendPoolName)
      }
      {
        id: resourceId(networkingResourceGroupName,'Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, applicationGatewayAdeAppApiGatewayVmBackendPoolName)
      }
    ]
    name: 'vm-${appEnvironment}-adeweb03'
    availabilityZone: '3'
    identityType: 'SystemAssigned'
    proximityPlacementGroupId: proximityPlacementGroupModule.outputs.ppgProperties[2].resourceId
    vmSize: 'Standard_B1s'
    imageReference: virtualMachineImageReference
    osType: 'Linux'
    osDiskName: 'disk-${appEnvironment}-adeweb03-os'
    createOption: 'FromImage'
    storageAccountType: 'Standard_LRS'
    managedIdentityId: virtualMachineManagedIdentity.properties.principalId
    dataCollectionRuleId: dataCollectionRule.id
  }
]

// Variables - Virtual Machine Scale Set
//////////////////////////////////////////////////
var virtualMachineScaleSets = [
  {
    name: 'vmss-${appEnvironment}-adeapp-vmss'
    skuName: 'Standard_B1s'
    tier: 'Standard'
    capacity: 1
    identityType: 'SystemAssigned'
    overprovision: true
    upgradePolicyMode: 'Automatic'
    singlePlacementGroup: false
    zoneBalance: true
    imageReference: virtualMachineImageReference
    createOption: 'FromImage'
    nicName: 'nic-${appEnvironment}-adeapp-vmss'
    subnetId: spokeVirtualNetwork::adeAppVmssSubnet.id
    loadBalancerBackendPoolId: loadBalancerModule.outputs.loadBalancerProperties[1].resourceId
    applicationGatewayBackendPoolIds: null
    managedIdentityId: virtualMachineManagedIdentity.properties.principalId
    dataCollectionRuleId: dataCollectionRule.id
  }
  {
    name: 'vmss-${appEnvironment}-adeweb-vmss'
    skuName: 'Standard_B1s'
    tier: 'Standard'
    capacity: 1
    identityType: 'SystemAssigned'
    overprovision: true
    upgradePolicyMode: 'Automatic'
    singlePlacementGroup: false
    zoneBalance: true
    imageReference: virtualMachineImageReference
    createOption: 'FromImage'
    nicName: 'nic-${appEnvironment}-adeweb-vmss'
    subnetId: spokeVirtualNetwork::adeWebVmssSubnet.id
    loadBalancerBackendPoolId: null
    applicationGatewayBackendPoolIds: [
      {
        id: resourceId(networkingResourceGroupName, 'Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, applicationGatewayAdeAppFrontendVmssBackendPoolName)
      }
      {
        id: resourceId(networkingResourceGroupName,'Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, applicationGatewayAdeAppApiGatewayVmssBackendPoolName)
      }
    ]
    managedIdentityId: virtualMachineManagedIdentity.properties.principalId
    dataCollectionRuleId: dataCollectionRule.id
  }
]

// Variables - Virtual Machine and Virtual Machine Scale Set Dns Records
//////////////////////////////////////////////////
var vmAndVmssARecords = [
  {
    name: 'ade-frontend-vm'
    ttl: 3600
    ipv4Address: publicIpAddress.properties.ipAddress
  }
  {
    name: 'ade-frontend-vmss'
    ttl: 3600
    ipv4Address: publicIpAddress.properties.ipAddress
  }
  {
    name: 'ade-apigateway-vm'
    ttl: 3600
    ipv4Address: publicIpAddress.properties.ipAddress
  }
  {
    name: 'ade-apigateway-vmss'
    ttl: 3600
    ipv4Address: publicIpAddress.properties.ipAddress
  }
]

// Variables - Virtual Machine Alerts
//////////////////////////////////////////////////
var metricAlertProperties = {
  name: 'virtual machines - cpu utilization'
  description: 'virtual machines - cpu utilization'
  enabled: true 
  scopes: [
    subscription().id
  ]
  severity: 2
  evaluationFrequency: 'PT1M'
  windowSize: 'PT5M'
  targetResourceType: 'microsoft.compute/virtualmachines'
  targetResourceRegion: location
  criteria: {
    'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
    allOf: [
      {
        name: 'Metric1'
        criterionType: 'StaticThresholdCriterion'
        metricName: 'Percentage CPU'
        metricNamespace: 'microsoft.compute/virtualmachines'
        dimensions: []
        operator: 'GreaterThan'
        threshold: 75
        timeAggregation: 'Average'
      }
    ]
  }
  actions: [
    {
      actionGroupId: actionGroup.id
    }
  ]
}

// Variables - Existing Resources
//////////////////////////////////////////////////
var actionGroupName = 'ag-${appEnvironment}-virtualmachine'
var adeAppVmssSubnetName = 'snet-${appEnvironment}-app-vmss'
var adeAppVmSubnetName = 'snet-${appEnvironment}-app-vm'
var adeWebVmssSubnetName = 'snet-${appEnvironment}-web-vmss'
var adeWebVmSubnetName = 'snet-${appEnvironment}-web-vm'
var applicationGatewayAdeAppApiGatewayVmBackendPoolName = 'backendPool-apigateway-vm'
var applicationGatewayAdeAppApiGatewayVmssBackendPoolName = 'backendPool-apigateway-vmss'
var applicationGatewayAdeAppFrontendVmBackendPoolName = 'backendPool-frontend-vm'
var applicationGatewayAdeAppFrontendVmssBackendPoolName = 'backendPool-frontend-vmss'
var applicationGatewayPublicIpAddressName = 'pip-${appEnvironment}-appgw'
var applicationGatewayName = 'appgw-${appEnvironment}'
var dataCollectionRuleName = 'dcr-${appEnvironment}-vmInsights'
var eventHubNamespaceAuthorizationRuleName = 'RootManageSharedAccessKey'
var eventHubNamespaceName = 'evhns-${appEnvironment}-diagnostics'
var keyVaultName = replace('kv-${appEnvironment}', '-', '')
var logAnalyticsWorkspaceName = 'log-${appEnvironment}'
var spokeVirtualNetworkName = 'vnet-${appEnvironment}-spoke'
var storageAccountName = replace('sa-diag-${uniqueString(subscription().subscriptionId)}', '-', '')
var virtualMachineManagedIdentityName = 'id-${appEnvironment}-virtualmachine'

// Existing Resource - Action Group
//////////////////////////////////////////////////
resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: actionGroupName
}

// Existing Resource - Dns Zone
//////////////////////////////////////////////////
resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' existing = {
  scope: resourceGroup(dnsZoneResourceGroupName)
  name: rootDomainName
}

// Existing Resource - Data Collection Rule - VM Insights
//////////////////////////////////////////////////
resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: dataCollectionRuleName
}

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

// Existing Resource - Managed Identity - Virtual Machine
//////////////////////////////////////////////////
resource virtualMachineManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup(securityResourceGroupName)
  name: virtualMachineManagedIdentityName
}

// Existing Resource - Public Ip Address - Application Gateway
//////////////////////////////////////////////////
resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-09-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: applicationGatewayPublicIpAddressName
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
    loadBalancers: loadBalancers
    loadBalancerServices: loadBalancerServices
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
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
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
    tags: tags
    virtualMachineScaleSets: virtualMachineScaleSets
  }
}

// Module - Virtual Machine and Virtual Machine Scale Set Dns Records
//////////////////////////////////////////////////
module vmAndVmssDnsRecordsModule 'virtual_machine_dns.bicep' = {
  scope: resourceGroup(dnsZoneResourceGroupName)
  name: 'vmAndVmssDnsRecordsDeployment'
  params: {
    dnsARecords: vmAndVmssARecords
    dnsZoneName: dnsZone.name
  }
}

// Module - Virtual Machine Alerts
//////////////////////////////////////////////////
module vmAndVmssAlertsModule 'metric_alert.bicep' = {
  name: 'vmAndVmssAlertsDeployment'
  params: {
    metricAlertProperties: metricAlertProperties
    tags: tags
  }
}
