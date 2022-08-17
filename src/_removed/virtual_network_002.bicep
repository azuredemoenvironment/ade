// Parameters
//////////////////////////////////////////////////
@description('The name of the ADE AKS Subnet.')
param adeAppAksSubnetName string

@description('The address prefix of the ADE AKS Subnet.')
param adeAppAksSubnetPrefix string

@description('The name of the ADE App SQL Subnet.')
param adeAppSqlSubnetName string

@description('The ID of the ADE App SQL Subnet Nsg.')
param adeAppSqlSubnetNsgId string

@description('The address prefix of the ADE App SQL Subnet.')
param adeAppSqlSubnetPrefix string

@description('The name of the ADE App Vmss Subnet.')
param adeAppVmssSubnetName string

@description('The ID of the ADE App Vmss Subnet Nsg.')
param adeAppVmssSubnetNsgId string

@description('The address prefix of the ADE App Vmss Subnet.')
param adeAppVmssSubnetPrefix string

@description('The name of the ADE App Vm Subnet.')
param adeAppVmSubnetName string

@description('The ID of the ADE App Vm Subnet Nsg.')
param adeAppVmSubnetNsgId string

@description('The address prefix of the ADE App Vm Subnet.')
param adeAppVmSubnetPrefix string

@description('The name of the ADE Web Vmss Subnet.')
param adeWebVmssSubnetName string

@description('The ID of the ADE Web Vmss Subnet Nsg.')
param adeWebVmssSubnetNsgId string

@description('The address prefix of the ADE Web Vmss Subnet.')
param adeWebVmssSubnetPrefix string

@description('The name of the ADE Web Vm Subnet.')
param adeWebVmSubnetName string

@description('The ID of the ADE Web Vm Subnet Nsg.')
param adeWebVmSubnetNsgId string

@description('The address prefix of the ADE Web Vm Subnet.')
param adeWebVmSubnetPrefix string

@description('The name of the Data Ingestor Subnet.')
param dataIngestorServiceSubnetName string

@description('The ID of the Data Ingestor Subnet Nsg.')
param dataIngestorServiceSubnetNsgId string

@description('The address prefix of the Data Ingestor Subnet.')
param dataIngestorServiceSubnetPrefix string

@description('The name of the Data Reporter Subnet.')
param dataReporterServiceSubnetName string

@description('The ID of the Data Reporter Subnet Nsg.')
param dataReporterServiceSubnetNsgId string

@description('The address prefix of the Data Reporter Subnet.')
param dataReporterServiceSubnetPrefix string

@description('The ID of the Diagnostics Storage Account.')
param diagnosticsStorageAccountId string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The name of the Event Ingestor Subnet.')
param eventIngestorServiceSubnetName string

@description('The ID of the Event Ingestor Subnet Nsg.')
param eventIngestorServiceSubnetNsgId string

@description('The address prefix of the Event Ingestor Subnet.')
param eventIngestorServiceSubnetPrefix string

@description('The name of the Inspector Gadget SQL Subnet.')
param inspectorGadgetSqlSubnetName string

@description('The ID of the Inspector Gadget SQL Subnet Nsg.')
param inspectorGadgetSqlSubnetNsgId string

@description('The address prefix of the Inspector Gadget SQL Subnet.')
param inspectorGadgetSqlSubnetPrefix string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The ID of the Nat Gateway.')
param natGatewayId string

@description('The name of the User Service Subnet.')
param userServiceSubnetName string

@description('The ID of the User Service Subnet Nsg.')
param userServiceSubnetNsgId string

@description('The address prefix of the User Service Subnet.')
param userServiceSubnetPrefix string

@description('The name of the Virtual Network.')
param virtualNetwork002Name string

@description('The address prefix of the Virtual Network.')
param virtualnetwork002Prefix string

@description('The name of the VNET Integration Subnet.')
param vnetIntegrationSubnetName string

@description('The ID of the VNET Integration Subnet Nsg.')
param vnetIntegrationSubnetNsgId string

@description('The address prefix of the VNET Integration Subnet.')
param vnetIntegrationSubnetPrefix string

// Variables
//////////////////////////////////////////////////
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
        name: adeAppAksSubnetName
        properties: {
          addressPrefix: adeAppAksSubnetPrefix
          serviceEndpoints: [
            {
              service: 'Microsoft.ContainerRegistry'
            }
          ]
        }
      }
      {
        name: adeAppSqlSubnetName
        properties: {
          addressPrefix: adeAppSqlSubnetPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: adeAppSqlSubnetNsgId
          }
        }
      }
      {
        name: adeAppVmssSubnetName
        properties: {
          addressPrefix: adeAppVmssSubnetPrefix
          networkSecurityGroup: {
            id: adeAppVmssSubnetNsgId
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
        name: adeAppVmSubnetName
        properties: {
          addressPrefix: adeAppVmSubnetPrefix
          networkSecurityGroup: {
            id: adeAppVmSubnetNsgId
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
            id: adeWebVmssSubnetNsgId
          }
        }
      }
      {
        name: adeWebVmSubnetName
        properties: {
          addressPrefix: adeWebVmSubnetPrefix
          networkSecurityGroup: {
            id: adeWebVmSubnetNsgId
          }
        }
      }
      {
        name: dataIngestorServiceSubnetName
        properties: {
          addressPrefix: dataIngestorServiceSubnetPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: dataIngestorServiceSubnetNsgId
          }
        }
      }
      {
        name: dataReporterServiceSubnetName
        properties: {
          addressPrefix: dataReporterServiceSubnetPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: dataReporterServiceSubnetNsgId
          }
        }
      }   
      {
        name: eventIngestorServiceSubnetName
        properties: {
          addressPrefix: eventIngestorServiceSubnetPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: eventIngestorServiceSubnetNsgId
          }
        }
      }
      {
        name: inspectorGadgetSqlSubnetName
        properties: {
          addressPrefix: inspectorGadgetSqlSubnetPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: inspectorGadgetSqlSubnetNsgId
          }
        }
      }
      {
        name: userServiceSubnetName
        properties: {
          addressPrefix: userServiceSubnetPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: userServiceSubnetNsgId
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
          networkSecurityGroup: {
            id: vnetIntegrationSubnetNsgId
          }
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
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'VMProtectionAlerts'
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
output virtualNetwork002Id string = virtualNetwork002.id
