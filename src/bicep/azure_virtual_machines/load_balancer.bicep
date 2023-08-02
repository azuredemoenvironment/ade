// Parameters
//////////////////////////////////////////////////
@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The array of properties for Load Balancer.')
param loadBalancers array

@description('The array of properties for Load Balancer services.')
param loadBalancerServices array

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The ID of the Storage Account.')
param storageAccountId string

@description('The list of resource tags.')
param tags object

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
    probes: [for (loadBalancerService, i) in loadBalancerServices: {
      name: loadBalancerService.probeName
      properties: {
        protocol: loadBalancerService.probeProtocol
        requestPath: loadBalancerService.requestPath
        port: loadBalancerService.port
        intervalInSeconds: loadBalancerService.intervalInSeconds
        numberOfProbes: loadBalancerService.numberOfProbes
      }
    }]
    loadBalancingRules: [for (loadBalancerService, i) in loadBalancerServices: {
      name: loadBalancerService.loadBalancingRuleName
      properties: {
        frontendIPConfiguration: {
          id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancer.name, 'frontendIPConfiguration')
        }
        backendAddressPool: {
          id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancer.name, 'backendAddressPool')
        }
        probe: {
          id: resourceId('Microsoft.Network/loadBalancers/probes', loadBalancer.name, loadBalancerService.probeName)
        }
        protocol: loadBalancerService.loadBalancingRuleProtocol
        frontendPort: loadBalancerService.port
        backendPort: loadBalancerService.port
        idleTimeoutInMinutes: loadBalancerService.idleTimeoutInMinutes
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
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
      {
        category: 'LoadBalancerProbeHealthStatus'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
    ]
  }
}]

// Outputs
//////////////////////////////////////////////////
output loadBalancerProperties array = [for (loadBalancer, i) in loadBalancers: {
  resourceId: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancer.name, 'backendAddressPool')
}]
