// parameters
param location string
param adminUserName string
param adminPassword string
param logAnalyticsWorkspaceId string
param logAnalyticsWorkspaceCustomerId string
param logAnalyticsWorkspaceKey string
param nTierWebSubnetId string
param nTierAppSubnetId string
param proximityPlacementGroupAz1Name string
param proximityPlacementGroupAz2Name string
param proximityPlacementGroupAz3Name string
param nTierAppLoadBalancerName string
param nTierAppLoadBalancerPrivateIpAddress string
param nTierApp01Name string
param nTierApp01NICName string
param nTierApp01OSDiskName string
param nTierApp01PrivateIpAddress string
param nTierApp02Name string
param nTierApp02NICName string
param nTierApp02OSDiskName string
param nTierApp02PrivateIpAddress string
param nTierApp03Name string
param nTierApp03NICName string
param nTierApp03OSDiskName string
param nTierApp03PrivateIpAddress string
param nTierWeb01Name string
param nTierWeb01NICName string
param nTierWeb01OSDiskName string
param nTierWeb01PrivateIpAddress string
param nTierWeb02Name string
param nTierWeb02NICName string
param nTierWeb02OSDiskName string
param nTierWeb02PrivateIpAddress string
param nTierWeb03Name string
param nTierWeb03NICName string
param nTierWeb03OSDiskName string
param nTierWeb03PrivateIpAddress string

// variables
var environmentName = 'production'
var functionName = 'nTier'
var costCenterName = 'it'

// resource - proximity placement group - availability zone 1
resource proximityPlacementGroupAz1 'Microsoft.Compute/proximityPlacementGroups@2020-12-01' = {
  name: proximityPlacementGroupAz1Name
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    proximityPlacementGroupType: 'Standard'
  }
}

// resource - proximity placement group - availability zone 2
resource proximityPlacementGroupAz2 'Microsoft.Compute/proximityPlacementGroups@2020-12-01' = {
  name: proximityPlacementGroupAz2Name
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    proximityPlacementGroupType: 'Standard'
  }
}

// resource - proximity placement group - availability zone 3
resource proximityPlacementGroupAz3 'Microsoft.Compute/proximityPlacementGroups@2020-12-01' = {
  name: proximityPlacementGroupAz3Name
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    proximityPlacementGroupType: 'Standard'
  }
}

// resource - load balancer - ntierapp
resource nTierAppLoadBalancer 'Microsoft.Network/loadBalancers@2020-11-01' = {
  name: nTierAppLoadBalancerName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'fip-nTierApp'
        properties: {
          subnet: {
            id: nTierAppSubnetId
          }
          privateIPAddress: nTierAppLoadBalancerPrivateIpAddress
          privateIPAllocationMethod: 'Static'
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'bep-nTierApp'
      }
    ]
    probes: [
      {
        name: 'probe-nTierApp'
        properties: {
          protocol: 'Https'
          requestPath: '/'
          port: 443
          intervalInSeconds: 15
          numberOfProbes: 2
        }
      }
    ]
    loadBalancingRules: [
      {
        name: 'lbr-nTierApp'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', nTierAppLoadBalancerName, 'fip-nTierApp')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', nTierAppLoadBalancerName, 'bep-nTierApp')
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', nTierAppLoadBalancerName, 'probe-nTierApp')
          }
          protocol: 'Tcp'
          frontendPort: 443
          backendPort: 443
          idleTimeoutInMinutes: 15
        }
      }
    ]
  }
}

// resource - load balancer - diagnostic settings - ntierapp
resource nTierAppLoadBalancerDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: nTierAppLoadBalancer
  name: '${nTierAppLoadBalancer.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'LoadBalancerAlertEvent'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'LoadBalancerProbeHealthStatus'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

var ntierVirtualMachines = [
  {
    name: nTierApp01Name
    nicName: nTierApp01NICName
    osDiskName: nTierApp01OSDiskName
    privateIpAddress: nTierApp01PrivateIpAddress
    subnetId: nTierAppSubnetId
    zone: '1'
    proximityPlacementGroupId: proximityPlacementGroupAz1.id
    adeModule: 'backend'
  }
  {
    name: nTierApp02Name
    nicName: nTierApp02NICName
    osDiskName: nTierApp02OSDiskName
    privateIpAddress: nTierApp02PrivateIpAddress
    subnetId: nTierAppSubnetId
    zone: '2'
    proximityPlacementGroupId: proximityPlacementGroupAz2.id
    adeModule: 'backend'
  }
  {
    name: nTierApp03Name
    nicName: nTierApp03NICName
    osDiskName: nTierApp03OSDiskName
    privateIpAddress: nTierApp03PrivateIpAddress
    subnetId: nTierAppSubnetId
    zone: '3'
    proximityPlacementGroupId: proximityPlacementGroupAz3.id
    adeModule: 'backend'
  }
  {
    name: nTierWeb01Name
    nicName: nTierWeb01NICName
    osDiskName: nTierWeb01OSDiskName
    privateIpAddress: nTierWeb01PrivateIpAddress
    subnetId: nTierWebSubnetId
    zone: '1'
    proximityPlacementGroupId: proximityPlacementGroupAz1.id
    adeModule: 'backend'
  }
  {
    name: nTierWeb02Name
    nicName: nTierWeb02NICName
    osDiskName: nTierWeb02OSDiskName
    privateIpAddress: nTierWeb02PrivateIpAddress
    subnetId: nTierWebSubnetId
    zone: '2'
    proximityPlacementGroupId: proximityPlacementGroupAz2.id
    adeModule: 'backend'
  }
  {
    name: nTierWeb03Name
    nicName: nTierWeb03NICName
    osDiskName: nTierWeb03OSDiskName
    privateIpAddress: nTierWeb03PrivateIpAddress
    subnetId: nTierWebSubnetId
    zone: '3'
    proximityPlacementGroupId: proximityPlacementGroupAz3.id
    adeModule: 'backend'
  }
]
module AzureVirtualMachinesNTierVm 'azure_virtual_machines_ntier_vm.bicep' = [for nTierVirtualMachine in ntierVirtualMachines: {
  name: 'nTierVirtualMachineDeployments-${nTierVirtualMachine.name}'
  params: {
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    logAnalyticsWorkspaceCustomerId: logAnalyticsWorkspaceCustomerId
    logAnalyticsWorkspaceKey: logAnalyticsWorkspaceKey
    adminUserName: adminUserName
    adminPassword: adminPassword
    name: nTierVirtualMachine.name
    nicName: nTierVirtualMachine.nicName
    osDiskName: nTierVirtualMachine.osDiskName
    privateIpAddress: nTierVirtualMachine.privateIpAddress
    subnetId: nTierVirtualMachine.subnetId
    proximityPlacementGroupId: nTierVirtualMachine.proximityPlacementGroupId
    zone: nTierVirtualMachine.zone
    adeModule: nTierVirtualMachine.adeModule
    tags: {
      environment: environmentName
      function: functionName
      costCenter: costCenterName
    }
  }
}]
