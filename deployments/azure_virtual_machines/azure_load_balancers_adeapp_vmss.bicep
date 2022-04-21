// Parameters
//////////////////////////////////////////////////
@description('The name of the ADE App Vmss Load Balancer.')
param adeAppVmssLoadBalancerName string

@description('The private Ip address of the ADE App Vmss Load Balancer.')
param adeAppVmssLoadBalancerPrivateIpAddress string

@description('The ID of the ADE App Vmss Subnet.')
param adeAppVmssSubnetId string

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

// Resource - Load Balancer - ADE App Vmss
//////////////////////////////////////////////////
resource adeAppVmssLoadBalancer 'Microsoft.Network/loadBalancers@2020-11-01' = {
  name: adeAppVmssLoadBalancerName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'fip-adeAppVmss'
        properties: {
          subnet: {
            id: adeAppVmssSubnetId
          }
          privateIPAddress: adeAppVmssLoadBalancerPrivateIpAddress
          privateIPAllocationMethod: 'Static'
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'bep-adeAppVmss'
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
          id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', adeAppVmssLoadBalancerName, 'fip-adeAppVmss')
        }
        backendAddressPool: {
          id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', adeAppVmssLoadBalancerName, 'bep-adeAppVmss')
        }
        probe: {
          id: resourceId('Microsoft.Network/loadBalancers/probes', adeAppVmssLoadBalancerName, 'probe-${backendService.name}')
        }
        protocol: 'Tcp'
        frontendPort: backendService.port
        backendPort: backendService.port
        idleTimeoutInMinutes: 15
      }
    }]
  }
}

// Resource - Load Balancer - Diagnostic Settings - ADE App Vmss
//////////////////////////////////////////////////
resource adeAppVmssLoadBalancerDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: adeAppVmssLoadBalancer
  name: '${adeAppVmssLoadBalancer.name}-diagnostics'
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
output adeAppVmssLoadBalancerBackendPoolId string = resourceId('Microsoft.Network/loadBalancers/backendAddressPools', adeAppVmssLoadBalancerName, 'bep-adeAppVmss')
