// Parameters
//////////////////////////////////////////////////
@description('The ID of the Diagnostics Storage Account.')
param diagnosticsStorageAccountId string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The list of Resource tags')
param tags object

@description('The array of properties for Load Balancer backend services.')
param loadBalancerBackendServices array

@description('The array of properties for Load Balancer.')
param loadBalancers array

// Resource - Load Balancer
//////////////////////////////////////////////////
resource lb 'Microsoft.Network/loadBalancers@2020-11-01' = [for (loadBalancer, i) in loadBalancers: {
  name: loadBalancer.name
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: loadBalancer.properties.frontendIPConfigurations
    backendAddressPools: [
      {
        name: 'bep-${loadBalancer.name}'
      }
    ]
    probes: [for (loadBalancerBackendService, i) in loadBalancerBackendServices: {
      name: 'probe-${loadBalancerBackendService.name}'
      properties: {
        protocol: 'Http'
        requestPath: '/swagger/index.html'
        port: loadBalancerBackendService.port
        intervalInSeconds: 15
        numberOfProbes: 2
      }
    }]
    loadBalancingRules: [for (loadBalancerBackendService, i) in loadBalancerBackendServices: {
      name: 'lbr-${loadBalancerBackendService.name}'
      properties: {
        frontendIPConfiguration: {
          id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancer.name, 'fip-${loadBalancer.name}')
        }
        backendAddressPool: {
          id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancer.name, 'bep-${loadBalancer.name}')
        }
        probe: {
          id: resourceId('Microsoft.Network/loadBalancers/probes', loadBalancer.name, 'probe-${loadBalancerBackendService.name}')
        }
        protocol: 'Tcp'
        frontendPort: loadBalancerBackendService.port
        backendPort: loadBalancerBackendService.port
        idleTimeoutInMinutes: 15
      }
    }]
  }
}]

// Resource - Load Balancer - Diagnostic Settings
//////////////////////////////////////////////////
resource lbDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = [for (loadBalancer, i) in loadBalancers: {
  scope: lb[i]
  name: '${loadBalancer.name}-diagnostics'
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
}]

// Outputs
//////////////////////////////////////////////////
output loadBalancerProperties array = [for (loadBalancer, i) in loadBalancers: {
  resourceId: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancer.name, 'bep-${loadBalancer.name}')
}]
