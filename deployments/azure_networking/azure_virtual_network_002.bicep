// Parameters
//////////////////////////////////////////////////
@description('The name of the AKS Subnet.')
param aksSubnetName string

@description('The address prefix of the AKS Subnet.')
param aksSubnetPrefix string

@description('The name of the Client Services Subnet.')
param clientServicesSubnetName string

@description('The ID of the Client Services Subnet NSG.')
param clientServicesSubnetNSGId string

@description('The address prefix of the Client Services Subnet.')
param clientServicesSubnetPrefix string

@description('The ID of the Route Table.')
param internetRouteTableId string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The ID of the Nat Gateway.')
param natGatewayId string

@description('The name of the NTier App Subnet.')
param nTierAppSubnetName string

@description('The ID of the NTier App Subnet NSG.')
param nTierAppSubnetNSGId string

@description('The address prefix of the NTier App Subnet.')
param nTierAppSubnetPrefix string

@description('The name of the NTier Web Subnet.')
param nTierWebSubnetName string

@description('The ID of the NTier Web Subnet NSG.')
param nTierWebSubnetNSGId string

@description('The address prefix of the NTier Web Subnet.')
param nTierWebSubnetPrefix string

@description('The name of the Private Endpoint Subnet.')
param privateEndpointSubnetName string

@description('The address prefix of the Private Endpoint Subnet.')
param privateEndpointSubnetPrefix string

@description('The name of the Virtual Network.')
param virtualNetwork002Name string

@description('The address prefix of the Virtual Network.')
param virtualnetwork002Prefix string

@description('The name of the VMSS Subnet.')
param vmssSubnetName string

@description('The ID of the VMSS Subnet NSG.')
param vmssSubnetNSGId string

@description('The address prefix of the VMSS Subnet.')
param vmssSubnetPrefix string

@description('The name of the VNET Integration Subnet.')
param vnetIntegrationSubnetName string

@description('The address prefix of the VNET Integration Subnet.')
param vnetIntegrationSubnetPrefix string

// Variables
//////////////////////////////////////////////////
var location = resourceGroup().location
var tags = {
  environment: 'production'
  function: 'networking'
  costCenter: 'it'
}

// Resource - Virtual Network
//////////////////////////////////////////////////
resource virtualNetwork002 'Microsoft.Network/virtualNetworks@2020-07-01' = {
  name: virtualNetwork002Name
  location: location
  tags: tags
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

// Resource - Virtual Network - Diagnostic Settings
//////////////////////////////////////////////////
resource virtualNetwork002Diagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${virtualNetwork002.name}-diagnostics'
  scope: virtualNetwork002
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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

// Outputs
//////////////////////////////////////////////////
output virtualNetwork002Id string = virtualNetwork002.id
