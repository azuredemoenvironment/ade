// Parameters
//////////////////////////////////////////////////
@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The list of resource tags.')
param tags object

@description('The array of properties for Load Balancer Load Balancing Rules.')
param loadBalancerLoadBalancingRules array

@description('The array of properties for Load Balancer Probes.')
param loadBalancerProbes array

@description('The array of properties for Load Balancer.')
param loadBalancers array

@description('The ID of the Storage Account.')
param storageAccountId string

// Resource - Load Balancer
//////////////////////////////////////////////////
resource lb 'Microsoft.Network/loadBalancers@2022-09-01' = [for (loadBalancer, i) in loadBalancers: {
  name: loadBalancer.name
  location: location
  tags: tags
  sku: {
    name: loadBalancer.sku.name
  }
  properties: {
    frontendIPConfigurations: loadBalancer.properties.frontendIPConfigurations
    backendAddressPools: loadBalancer.properties.backendAddressPools
    probes: [for (loadBalancerProbe, i) in loadBalancerProbes: {
      name: loadBalancerProbe.name
      properties: {
        protocol: loadBalancerProbe.protocol
        requestPath: loadBalancerProbe.requestPath
        port: loadBalancerProbe.port
        intervalInSeconds: loadBalancerProbe.intervalInSeconds
        numberOfProbes: loadBalancerProbe.numberOfProbes
      }
    }]
    loadBalancingRules: [for (loadBalancerLoadBalancingRule, i) in loadBalancerLoadBalancingRules: {
      name: 'lbr-${loadBalancerLoadBalancingRule.name}'
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
        protocol: loadBalancerLoadBalancingRule.protocol
        frontendPort: loadBalancerLoadBalancingRule.port
        backendPort: loadBalancerLoadBalancingRule.port
        idleTimeoutInMinutes: loadBalancerLoadBalancingRule.idleTimeoutInMinutes
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
    storageAccountId: storageAccountId
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
