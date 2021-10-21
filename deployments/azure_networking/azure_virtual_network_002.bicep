// Parameters
//////////////////////////////////////////////////
@description('The name of the ADE AKS Subnet.')
param adeAksSubnetName string

@description('The address prefix of the ADE AKS Subnet.')
param adeAksSubnetPrefix string

@description('The name of the ADE App Vmss Subnet.')
param adeAppVmssSubnetName string

@description('The ID of the ADE App Vmss Subnet NSG.')
param adeAppVmssSubnetNSGId string

@description('The address prefix of the ADE App Vmss Subnet.')
param adeAppVmssSubnetPrefix string

@description('The name of the ADE App Vm Subnet.')
param adeAppVmSubnetName string

@description('The ID of the ADE App Vm Subnet NSG.')
param adeAppVmSubnetNSGId string

@description('The address prefix of the ADE App Vm Subnet.')
param adeAppVmSubnetPrefix string

@description('The name of the ADE Web Vmss Subnet.')
param adeWebVmssSubnetName string

@description('The ID of the ADE Web Vmss Subnet NSG.')
param adeWebVmssSubnetNSGId string

@description('The address prefix of the ADE Web Vmss Subnet.')
param adeWebVmssSubnetPrefix string

@description('The name of the ADE Web Vm Subnet.')
param adeWebVmSubnetName string

@description('The ID of the ADE Web Vm Subnet NSG.')
param adeWebVmSubnetNSGId string

@description('The address prefix of the ADE Web Vm Subnet.')
param adeWebVmSubnetPrefix string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The ID of the Nat Gateway.')
param natGatewayId string

@description('The name of the Private Endpoint Subnet.')
param privateEndpointSubnetName string

@description('The address prefix of the Private Endpoint Subnet.')
param privateEndpointSubnetPrefix string

@description('The name of the Virtual Network.')
param virtualNetwork002Name string

@description('The address prefix of the Virtual Network.')
param virtualnetwork002Prefix string

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
        name: adeWebVmSubnetName
        properties: {
          addressPrefix: adeWebVmSubnetPrefix
          networkSecurityGroup: {
            id: adeWebVmSubnetNSGId
          }
        }
      }
      {
        name: adeAppVmSubnetName
        properties: {
          addressPrefix: adeAppVmSubnetPrefix
          networkSecurityGroup: {
            id: adeAppVmSubnetNSGId
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Sql'
            }
          ]
          natGateway: {
            id: natGatewayId
          }
        }
      }
      {
        name: adeWebVmssSubnetName
        properties: {
          addressPrefix: adeWebVmssSubnetPrefix
          networkSecurityGroup: {
            id: adeWebVmssSubnetNSGId
          }
        }
      }
      {
        name: adeAppVmssSubnetName
        properties: {
          addressPrefix: adeAppVmssSubnetPrefix
          networkSecurityGroup: {
            id: adeAppVmssSubnetNSGId
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Sql'
            }
          ]
          natGateway: {
            id: natGatewayId
          }
        }
      }
      {
        name: adeAksSubnetName
        properties: {
          addressPrefix: adeAksSubnetPrefix
          serviceEndpoints: [
            {
              service: 'Microsoft.ContainerRegistry'
            }
          ]
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
