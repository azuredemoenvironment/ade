// parameters
param location string
param adminUserName string
param adminPassword string
param logAnalyticsWorkspaceId string
param logAnalyticsWorkspaceCustomerId string
param logAnalyticsWorkspaceKey string
param appConfigConnectionString string
param acrServerName string
param acrPassword string
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
    probes: [for backendService in backendServices: {
      name: 'probe-${backendService.name}'
      properties: {
        protocol: 'Http'
        requestPath: '/swagger/index.html'
        port: backendService.port
        intervalInSeconds: 15
        numberOfProbes: 2
      }
    }]
    loadBalancingRules: [for backendService in backendServices: {
      name: 'lbr-${backendService.name}'
      properties: {
        frontendIPConfiguration: {
          id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', nTierAppLoadBalancerName, 'fip-nTierApp')
        }
        backendAddressPool: {
          id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', nTierAppLoadBalancerName, 'bep-nTierApp')
        }
        probe: {
          id: resourceId('Microsoft.Network/loadBalancers/probes', nTierAppLoadBalancerName, 'probe-${backendService.name}')
        }
        protocol: 'Tcp'
        frontendPort: backendService.port
        backendPort: backendService.port
        idleTimeoutInMinutes: 15
      }
    }]
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
    loadBalancerName: nTierAppLoadBalancerName
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
    loadBalancerName: nTierAppLoadBalancerName
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
    loadBalancerName: nTierAppLoadBalancerName
  }
  {
    name: nTierWeb01Name
    nicName: nTierWeb01NICName
    osDiskName: nTierWeb01OSDiskName
    privateIpAddress: nTierWeb01PrivateIpAddress
    subnetId: nTierWebSubnetId
    zone: '1'
    proximityPlacementGroupId: proximityPlacementGroupAz1.id
    adeModule: 'frontend'
    loadBalancerName: ''
  }
  {
    name: nTierWeb02Name
    nicName: nTierWeb02NICName
    osDiskName: nTierWeb02OSDiskName
    privateIpAddress: nTierWeb02PrivateIpAddress
    subnetId: nTierWebSubnetId
    zone: '2'
    proximityPlacementGroupId: proximityPlacementGroupAz2.id
    adeModule: 'frontend'
    loadBalancerName: ''
  }
  {
    name: nTierWeb03Name
    nicName: nTierWeb03NICName
    osDiskName: nTierWeb03OSDiskName
    privateIpAddress: nTierWeb03PrivateIpAddress
    subnetId: nTierWebSubnetId
    zone: '3'
    proximityPlacementGroupId: proximityPlacementGroupAz3.id
    adeModule: 'frontend'
    loadBalancerName: ''
  }
]
module AzureVirtualMachinesNTierVm 'azure_virtual_machines_ntier_vm.bicep' = [for nTierVirtualMachine in ntierVirtualMachines: {
  name: 'nTierVirtualMachineDeployments-${nTierVirtualMachine.name}'
  params: {
    adeModule: nTierVirtualMachine.adeModule
    adminPassword: adminPassword
    adminUserName: adminUserName
    location: location
    logAnalyticsWorkspaceCustomerId: logAnalyticsWorkspaceCustomerId
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    logAnalyticsWorkspaceKey: logAnalyticsWorkspaceKey
    appConfigConnectionString: appConfigConnectionString
    acrServerName: acrServerName
    acrPassword: acrPassword
    name: nTierVirtualMachine.name
    nicName: nTierVirtualMachine.nicName
    nTierAppLoadBalancerName: nTierVirtualMachine.loadBalancerName
    nTierAppLoadBalancerPrivateIpAddress: nTierAppLoadBalancerPrivateIpAddress
    osDiskName: nTierVirtualMachine.osDiskName
    privateIpAddress: nTierVirtualMachine.privateIpAddress
    proximityPlacementGroupId: nTierVirtualMachine.proximityPlacementGroupId
    subnetId: nTierVirtualMachine.subnetId
    zone: nTierVirtualMachine.zone
    tags: {
      environment: environmentName
      function: functionName
      costCenter: costCenterName
    }
  }
}]
