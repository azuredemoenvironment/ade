// parameters
param location string = resourceGroup().location
param aliasRegion string
param sourceAddressPrefix string
param virtualNetwork01ResourceGroupName string
param virtualNetwork001Name string
param virtualNetwork002Name string
param virtualNetwork003Name string

// variables
var virtualnetwork001Prefix = '10.101.0.0/16'
var azureFirewallSubnetName = 'AzureFirewallSubnet'
var azureFirewallSubnetPrefix = '10.101.0.0/24'
var azureBastionSubnetName = 'AzureBastionSubnet'
var azureBastionSubnetPrefix = '10.101.1.0/24'
var applicationgatewaySubnetName = 'ApplicationGatewaySubnet'
var applicationgatewaySubnetPrefix = '10.101.2.0/24'
var managementSubnetName = 'management'
var managementSubnetPrefix = '10.101.10.0/24'
var directoryServicesSubnetName = 'directoryServices'
var directoryServicesSubnetPrefix = '10.101.20.0/24'
var gatewaySubnetName = 'GatewaySubnet'
var gatewaySubnetPrefix = '10.101.255.0/24'
var virtualnetwork002Prefix = '10.102.0.0/16'
var developerSubnetName = 'developer'
var developerSubnetPrefix = '10.102.0.0/24'
var nTierWebSubnetName = 'ntierWeb'
var nTierWebSubnetPrefix = '10.102.10.0/24'
var nTierDBSubnetName = 'ntierDB'
var nTierDBSubnetPrefix = '10.102.11.0/24'
var vmssSubnetName = 'vmss'
var vmssSubnetPrefix = '10.102.20.0/24'
var clientServicesSubnetName = 'clientServices'
var clientServicesSubnetPrefix = '10.102.200.0/24'
var virtualnetwork003Prefix = '10.103.0.0/16'
var aksSubnetName = 'aks'
var aksSubnetPrefix = '10.103.10.0/24'
var aciSubnetName = 'aci'
var aciSubnetPrefix = '10.103.20.0/24'
var inspectorGadgetAppServicePrivateEndpointSubnetName = 'inspectorGadget-appservice-privateendpoint'
var inspectorGadgetAppServicePrivateEndpointSubnetPrefix = '10.103.30.0/24'
var inspectorGadgetAppServiceVnetIntegrationSubnetName = 'inspectorGadget-appservice-vnetintegration'
var inspectorGadgetAppServiceVnetIntegrationSubnetPrefix = '10.103.31.0/24'
var inspectorGadgetAzureSqlPrivateEndpointSubnetName = 'inspectorGadget-azuresql-privateendpoint'
var inspectorGadgetAzureSqlPrivateEndpointSubnetPrefix = '10.103.32.0/24'
var environmentName = 'production'
var functionName = 'networking'
var costCenterName = 'it'

// existing resources
// log analytics
param logAnalyticsWorkspaceResourceGroupName string
param logAnalyticsWorkspaceName string
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(logAnalyticsWorkspaceResourceGroupName)
}

// module - nat gateways
module natGatewayModule './azure_nat_gateway.bicep' = {
  name: 'natGatewayDeployment'
  params: {
    aliasRegion: aliasRegion
  }
}

// module - network security groups
module networkSecurityGroupsModule './azure_network_security_groups.bicep' = {
  name: 'networkSecurityGroupsDeployment'
  params: {
    aliasRegion: aliasRegion
    sourceAddressPrefix: sourceAddressPrefix
    logAnalyticsWorkspaceResourceGroupName: logAnalyticsWorkspaceResourceGroupName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}

// module - route tables
module routeTableModule './azure_route_table.bicep' = {
  name: 'routeTableDeployment'
  params: {
    aliasRegion: aliasRegion
  }
}

// resource - virtual network 001
resource virtualNetwork001 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: virtualNetwork001Name
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualnetwork001Prefix
      ]
    }
    subnets: [
      {
        name: azureFirewallSubnetName
        properties: {
          addressPrefix: azureFirewallSubnetPrefix
        }
      }
      {
        name: azureBastionSubnetName
        properties: {
          addressPrefix: azureBastionSubnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroupsModule.outputs.azureBastionSubnetNSGId
          }
        }
      }
      {
        name: applicationgatewaySubnetName
        properties: {
          addressPrefix: applicationgatewaySubnetPrefix
        }
      }
      {
        name: managementSubnetName
        properties: {
          addressPrefix: managementSubnetPrefix
          natGateway: {
            id: natGatewayModule.outputs.natGatewayId
          }
          networkSecurityGroup: {
            id: networkSecurityGroupsModule.outputs.managementSubnetNSGId
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
        }
      }
      {
        name: directoryServicesSubnetName
        properties: {
          addressPrefix: directoryServicesSubnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroupsModule.outputs.directoryServicesSubnetNSGId
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
        }
      }
      {
        name: gatewaySubnetName
        properties: {
          addressPrefix: gatewaySubnetPrefix
        }
      }
    ]
  }
}

// resource - virtual network 001 - diagnostic settings
resource virtualNetwork001Diagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${virtualNetwork001.name}-diagnostics'
  scope: virtualNetwork001
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

// resource - virtual network 002
resource virtualNetwork002 'Microsoft.Network/virtualNetworks@2020-06-01' = {
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
        name: developerSubnetName
        properties: {
          addressPrefix: developerSubnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroupsModule.outputs.developerSubnetNSGId
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
        }
      }
      {
        name: nTierWebSubnetName
        properties: {
          addressPrefix: nTierWebSubnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroupsModule.outputs.nTierWebSubnetNSGId
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
        }
      }
      {
        name: nTierDBSubnetName
        properties: {
          addressPrefix: nTierDBSubnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroupsModule.outputs.nTierDBSubnetNSGId
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
        }
      }
      {
        name: vmssSubnetName
        properties: {
          addressPrefix: vmssSubnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroupsModule.outputs.vmssSubnetNSGId
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
        }
      }
      {
        name: clientServicesSubnetName
        properties: {
          addressPrefix: clientServicesSubnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroupsModule.outputs.clientServicesSubnetNSGId
          }
          routeTable: {
            id: routeTableModule.outputs.internetRouteTableId
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
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
  scope: virtualNetwork001
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

// resource - virtual network 003
resource virtualNetwork003 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: virtualNetwork003Name
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualnetwork003Prefix
      ]
    }
    subnets: [
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
      {
        name: aciSubnetName
        properties: {
          addressPrefix: aciSubnetPrefix
          serviceEndpoints: [
            {
              service: 'Microsoft.ContainerRegistry'
            }
          ]
          delegations: [
            {
              name: 'aciDelegation'
              properties: {
                serviceName: 'Microsoft.ContainerInstance/containerGroups'
              }
            }
          ]
        }
      }
      {
        name: inspectorGadgetAppServicePrivateEndpointSubnetName
        properties: {
          addressPrefix: inspectorGadgetAppServicePrivateEndpointSubnetPrefix
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: inspectorGadgetAppServiceVnetIntegrationSubnetName
        properties: {
          addressPrefix: inspectorGadgetAppServiceVnetIntegrationSubnetPrefix
          delegations: [
            {
              name: 'aspDelegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: inspectorGadgetAzureSqlPrivateEndpointSubnetName
        properties: {
          addressPrefix: inspectorGadgetAzureSqlPrivateEndpointSubnetPrefix
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

// resource - virtual network 003 - diagnostic settings
resource virtualNetwork003Diagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${virtualNetwork003.name}-diagnostics'
  scope: virtualNetwork003
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

// module - azure bastion
module azureBastionModule './azure_bastion.bicep' = {
  name: 'azureBastionDeployment'
  params: {
    aliasRegion: aliasRegion
    logAnalyticsWorkspaceResourceGroupName: logAnalyticsWorkspaceResourceGroupName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    virtualNetwork01ResourceGroupName: virtualNetwork01ResourceGroupName
    virtualNetwork001Name: virtualNetwork001Name
  }
}