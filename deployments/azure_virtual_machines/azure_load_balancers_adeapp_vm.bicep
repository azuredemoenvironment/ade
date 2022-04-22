// Parameters
//////////////////////////////////////////////////
@description('The name of the ADE App Vm Load Balancer.')
param adeAppVmLoadBalancerName string

@description('The private Ip address of the ADE App Vm Load Balancer.')
param adeAppVmLoadBalancerPrivateIpAddress string

@description('The ID of the ADE App Vm Subnet.')
param adeAppVmSubnetId string

@description('Array of backend services for ADE App.')
param backendServices array

@description('The ID of the Diagnostics Storage Account.')
param diagnosticsStorageAccountId string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

// Variables
//////////////////////////////////////////////////
var tags = {
  environment: 'production'
  function: 'networking'
  costCenter: 'it'
}

// Resource - Load Balancer - ADE App Vm
//////////////////////////////////////////////////
resource adeAppVmLoadBalancer 'Microsoft.Network/loadBalancers@2020-11-01' = {
  name: adeAppVmLoadBalancerName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'fip-adeAppVm'
        properties: {
          subnet: {
            id: adeAppVmSubnetId
          }
          privateIPAddress: adeAppVmLoadBalancerPrivateIpAddress
          privateIPAllocationMethod: 'Static'
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'bep-adeAppVm'
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
          id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', adeAppVmLoadBalancerName, 'fip-adeAppVm')
        }
        backendAddressPool: {
          id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', adeAppVmLoadBalancerName, 'bep-adeAppVm')
        }
        probe: {
          id: resourceId('Microsoft.Network/loadBalancers/probes', adeAppVmLoadBalancerName, 'probe-${backendService.name}')
        }
        protocol: 'Tcp'
        frontendPort: backendService.port
        backendPort: backendService.port
        idleTimeoutInMinutes: 15
      }
    }]
  }
}

// Resource - Load Balancer - Diagnostic Settings - ADE App Vm
//////////////////////////////////////////////////
resource adeAppVmLoadBalancerDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: adeAppVmLoadBalancer
  name: '${adeAppVmLoadBalancer.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'LoadBalancerAlertEvent'
        enabled: true
      }
      {
        category: 'LoadBalancerProbeHealthStatus'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// Outputs
//////////////////////////////////////////////////
output adeAppVmLoadBalancerBackendPoolId string = resourceId('Microsoft.Network/loadBalancers/backendAddressPools', adeAppVmLoadBalancerName, 'bep-adeAppVm')
