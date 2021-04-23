// parameters
param location string
param monitorResourceGroupName string
param logAnalyticsWorkspaceName string
param virtualNetwork002Name string
param virtualnetwork002Prefix string
param nTierWebSubnetName string
param nTierWebSubnetPrefix string
param nTierAppSubnetName string
param nTierAppSubnetPrefix string
param vmssSubnetName string
param vmssSubnetPrefix string
param clientServicesSubnetName string
param clientServicesSubnetPrefix string
param vnetIntegrationSubnetName string
param vnetIntegrationSubnetPrefix string
param privateEndpointSubnetName string
param privateEndpointSubnetPrefix string
param aksSubnetName string
param aksSubnetPrefix string
param nTierWebSubnetNSGId string
param nTierAppSubnetNSGId string
param vmssSubnetNSGId string
param clientServicesSubnetNSGId string
param natGatewayId string
param internetRouteTableId string

// variables
var environmentName = 'production'
var functionName = 'networking'
var costCenterName = 'it'

// existing resources
// log analytics
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(monitorResourceGroupName)
}

// resource - virtual network 002
resource virtualNetwork002 'Microsoft.Network/virtualNetworks@2020-07-01' = {
  name: virtualNetwork002Name
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualnetwork002Prefix
      ]
    }
    subnets: [
      {
        name: nTierWebSubnetName
        properties: {
          addressPrefix: nTierWebSubnetPrefix
          networkSecurityGroup: {
            id: nTierWebSubnetNSGId
          }
        }
      }
      {
        name: nTierAppSubnetName
        properties: {
          addressPrefix: nTierAppSubnetPrefix
          natGateway: {
            id: natGatewayId
          }
          networkSecurityGroup: {
            id: nTierAppSubnetNSGId
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Sql'
            }
          ]
        }
      }
      {
        name: vmssSubnetName
        properties: {
          addressPrefix: vmssSubnetPrefix
          networkSecurityGroup: {
            id: vmssSubnetNSGId
          }
        }
      }
      {
        name: clientServicesSubnetName
        properties: {
          addressPrefix: clientServicesSubnetPrefix
          networkSecurityGroup: {
            id: clientServicesSubnetNSGId
          }
          routeTable: {
            id: internetRouteTableId
          }
        }
      }
      {
        name: vnetIntegrationSubnetName
        properties: {
          addressPrefix: vnetIntegrationSubnetPrefix
          delegations: [
            {
              name: 'appServicePlanDelegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: privateEndpointSubnetName
        properties: {
          addressPrefix: privateEndpointSubnetPrefix
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: aksSubnetName
        properties: {
          addressPrefix: aksSubnetPrefix
          serviceEndpoints: [
            {
              service: 'Microsoft.ContainerRegistry'
            }
          ]
        }
      }
    ]
  }
}

// resource - virtual network 002 - diagnostic settings
resource virtualNetwork002Diagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${virtualNetwork002.name}-diagnostics'
  scope: virtualNetwork002
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'VMProtectionAlerts'
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

output virtualNetwork002Id string = virtualNetwork002.id
