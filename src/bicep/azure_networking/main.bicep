// Parameters
//////////////////////////////////////////////////
@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('The current date.')
param currentDate string = utcNow('yyyy-MM-dd')

@description('Deploy Azure Firewall if value is set to true.')
param deployFirewall bool = true

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of the Management Resource Group.')
param managementResourceGroupName string

@description('The name of the owner of the deployment.')
param ownerName string

@description('The public IP address of the on-premises network.')
param sourceAddressPrefix string

// Variables
//////////////////////////////////////////////////
var tags = {
  deploymentDate: currentDate
  owner: ownerName
}

// Variables - Storage Account
//////////////////////////////////////////////////
var nsgFlowLogsStorageAccountName = replace('sa-nsgflow-${uniqueString(subscription().subscriptionId)}', '-', '')
var nsgFlowLogsStorageAccountProperties = {
  accessTier: 'Hot'
  httpsOnly: true
  kind: 'StorageV2'
  sku: 'Standard_GRS'
}

// Variables - Nat Gateway
//////////////////////////////////////////////////
var natGatewayName = 'ngw-${appEnvironment}'
var natGatewayProperties = {
  skuName: 'Standard'
  idleTimeoutInMinutes: 4
}
var publicIpPrefixName = 'pipp-${appEnvironment}-ngw'
var publicIpPrefixProperties = {
  skuName: 'Standard'
  prefixLength: 31
  publicIPAddressVersion: 'IPv4'
}

// Variables - Network Security Group
//////////////////////////////////////////////////
var networkSecurityGroups = [
  {
    name: 'nsg-${appEnvironment}-applicationGateway'
    properties: {
      securityRules: [
        {
          name: 'Gateway_Manager_Inbound'
          properties: {
            description: 'Allow Gateway Manager Access'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '65200-65535'
            sourceAddressPrefix: 'GatewayManager'
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 100
            direction: 'Inbound'
          }
        }
        {
          name: 'HTTP_Inbound'
          properties: {
            description: 'Allow HTTP Inbound'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '80'
            sourceAddressPrefix: '*'
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 200
            direction: 'Inbound'
          }
        }
        {
          name: 'HTTPS_Inbound'
          properties: {
            description: 'Allow HTTPS Inbound'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
            sourceAddressPrefix: '*'
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 300
            direction: 'Inbound'
          }
        }
      ]
    }
  }
  {
    name: 'nsg-${appEnvironment}-bastion'
    properties: {
      securityRules: [
        {
          name: 'HTTPS_Inbound'
          properties: {
            description: 'Allow HTTPS Access from Current Location'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
            sourceAddressPrefix: sourceAddressPrefix
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 100
            direction: 'Inbound'
          }
        }
        {
          name: 'Gateway_Manager_Inbound'
          properties: {
            description: 'Allow Gateway Manager Access'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
            sourceAddressPrefix: 'GatewayManager'
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 200
            direction: 'Inbound'
          }
        }
        {
          name: 'SSH_RDP_Outbound'
          properties: {
            description: 'Allow SSH and RDP Outbound'
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRanges: [
              '22'
              '3389'
            ]
            sourceAddressPrefix: '*'
            destinationAddressPrefix: 'VirtualNetwork'
            access: 'Allow'
            priority: 100
            direction: 'Outbound'
          }
        }
        {
          name: 'Azure_Cloud_Outbound'
          properties: {
            description: 'Allow Azure Cloud Outbound'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
            sourceAddressPrefix: '*'
            destinationAddressPrefix: 'AzureCloud'
            access: 'Allow'
            priority: 200
            direction: 'Outbound'
          }
        }
      ]
    }
  }
  {
    name: 'nsg-${appEnvironment}-adeWeb-vm'
    properties: {}
  }
  {
    name: 'nsg-${appEnvironment}-adeApp-vm'
    properties: {}
  }
  {
    name: 'nsg-${appEnvironment}-adeWeb-vmss'
    properties: {}
  }
  {
    name: 'nsg-${appEnvironment}-adeApp-vmss'
    properties: {}
  }
  {
    name: 'nsg-${appEnvironment}-userService'
    properties: {}
  }
  {
    name: 'nsg-${appEnvironment}-dataIngestorService'
    properties: {}
  }
  {
    name: 'nsg-${appEnvironment}-dataReporterService'
    properties: {}
  }
  {
    name: 'nsg-${appEnvironment}-eventIngestorService'
    properties: {}
  }
  {
    name: 'nsg-${appEnvironment}-adeAppSql'
    properties: {}
  }
  {
    name: 'nsg-${appEnvironment}-inspectorGadgetSql'
    properties: {}
  }
  {
    name: 'nsg-${appEnvironment}-vnetIntegration'
    properties: {}
  }
]

// Variables - Route Table
//////////////////////////////////////////////////
var routeTableName = 'rt-${appEnvironment}'
var routes = [
  {
    name: 'toInternet'
    addressPrefix: '0.0.0.0/0'
    nextHopType: 'VirtualAppliance'
    nextHopIpAddress: firewallPrivateIpAddress
  }
]

// Variables - Virtual Network
//////////////////////////////////////////////////
var hubVirtualNetworkName = 'vnet-${appEnvironment}-hub'
var hubVirtualNetworkPrefix = '10.101.0.0/16'
var hubVirtualNetworkSubnets = [  
  {
    name: 'AzureFirewallSubnet'
    properties: {
      addressPrefix: '10.101.1.0/24'
    }
  }
  {
    name: 'snet-${appEnvironment}-applicationGateway'
    properties: {
      addressPrefix: '10.101.11.0/24'
      networkSecurityGroup: {
        id: networkSecurityGroupModule.outputs.networkSecurityGroupProperties[0].resourceId
      }
      serviceEndpoints: [
        {
          service: 'Microsoft.Web'
        }
      ]
    }
  }
  {
    name: 'AzureBastionSubnet'
    properties: {
      addressPrefix: '10.101.21.0/24'
      networkSecurityGroup: {
        id: networkSecurityGroupModule.outputs.networkSecurityGroupProperties[1].resourceId
      }
    }
  }
  {
    name: 'GatewaySubnet'
    properties: {
      addressPrefix: '10.101.255.0/24'
    }
  }
]
var spokeVirtualNetworkName = 'vnet-${appEnvironment}-spoke'
var spokeVirtualNetworkPrefix = '10.102.0.0/16'
var spokeVirtualNetworkSubnets = [  
  {
    name: 'snet-${appEnvironment}-adeWeb-vm'
    properties: {
      addressPrefix: '10.102.1.0/24'
      natGateway: {
        id: natGatewayModule.outputs.natGatewayId
      }
      networkSecurityGroup: {
        id: networkSecurityGroupModule.outputs.networkSecurityGroupProperties[2].resourceId
      }
      serviceEndpoints: [
        {
          service: 'Microsoft.Sql'
        }
      ]
    }
  }
  {
    name: 'snet-${appEnvironment}-adeApp-vm'
    properties: {
      addressPrefix: '10.102.2.0/24'
      natGateway: {
        id: natGatewayModule.outputs.natGatewayId
      }
      networkSecurityGroup: {
        id: networkSecurityGroupModule.outputs.networkSecurityGroupProperties[3].resourceId
      }
      serviceEndpoints: [
        {
          service: 'Microsoft.Sql'
        }
      ]
    }
  }
  {
    name: 'snet-${appEnvironment}-adeWeb-vmss'
    properties: {
      addressPrefix: '10.102.11.0/24'
      natGateway: {
        id: natGatewayModule.outputs.natGatewayId
      }
      networkSecurityGroup: {
        id: networkSecurityGroupModule.outputs.networkSecurityGroupProperties[4].resourceId
      }
      serviceEndpoints: [
        {
          service: 'Microsoft.Sql'
        }
      ]
    }
  }
  {
    name: 'snet-${appEnvironment}-adeApp-vmss'
    properties: {
      addressPrefix: '10.102.12.0/24'
      natGateway: {
        id: natGatewayModule.outputs.natGatewayId
      }
      networkSecurityGroup: {
        id: networkSecurityGroupModule.outputs.networkSecurityGroupProperties[5].resourceId
      }
      serviceEndpoints: [
        {
          service: 'Microsoft.Sql'
        }
      ]
    }
  }
  {
    name: 'snet-${appEnvironment}-adeApp-aks'
    properties: {
      addressPrefix: '10.102.100.0/23'
      serviceEndpoints: [
        {
          service: 'Microsoft.ContainerRegistry'
        }
      ]
    }
  }
  {
    name: 'snet-${appEnvironment}-userService'
    properties: {
      addressPrefix: '10.102.151.0/24'
      networkSecurityGroup: {
        id: networkSecurityGroupModule.outputs.networkSecurityGroupProperties[6].resourceId
      }
      privateEndpointNetworkPolicies: 'Enabled'
    }
  }
  {
    name: 'snet-${appEnvironment}-dataIngestorService'
    properties: {
      addressPrefix: '10.102.152.0/24'
      networkSecurityGroup: {
        id: networkSecurityGroupModule.outputs.networkSecurityGroupProperties[7].resourceId
      }
      privateEndpointNetworkPolicies: 'Enabled'
    }
  }
  {
    name: 'snet-${appEnvironment}-dataReporterService'
    properties: {
      addressPrefix: '10.102.153.0/24'
      networkSecurityGroup: {
        id: networkSecurityGroupModule.outputs.networkSecurityGroupProperties[8].resourceId
      }
      privateEndpointNetworkPolicies: 'Enabled'
    }
  }
  {
    name: 'snet-${appEnvironment}-eventIngestorService'
    properties: {
      addressPrefix: '10.102.154.0/24'
      networkSecurityGroup: {
        id: networkSecurityGroupModule.outputs.networkSecurityGroupProperties[9].resourceId
      }
      privateEndpointNetworkPolicies: 'Enabled'
    }
  }
  {
    name: 'snet-${appEnvironment}-adeAppSql'
    properties: {
      addressPrefix: '10.102.160.0/24'
      networkSecurityGroup: {
        id: networkSecurityGroupModule.outputs.networkSecurityGroupProperties[10].resourceId
      }
      privateEndpointNetworkPolicies: 'Enabled'
    }
  }
  {
    name: 'snet-${appEnvironment}-inspectorGadgetSql'
    properties: {
      addressPrefix: '10.102.161.0/24'
      networkSecurityGroup: {
        id: networkSecurityGroupModule.outputs.networkSecurityGroupProperties[11].resourceId
      }
      privateEndpointNetworkPolicies: 'Enabled'
    }
  }
  {
    name: 'snet-${appEnvironment}-vnetIntegration'
    properties: {
      addressPrefix: '10.102.201.0/24'
      delegations: [
        {
          name: 'appServicePlanDelegation'
          properties: {
            serviceName: 'Microsoft.Web/serverFarms'
          }
        }
      ]
      networkSecurityGroup: {
        id: networkSecurityGroupModule.outputs.networkSecurityGroupProperties[12].resourceId
      }
      privateEndpointNetworkPolicies: 'Enabled'
    }
  }
]

// Variables - Firewall
//////////////////////////////////////////////////
var firewallName = 'fw-${appEnvironment}'
var firewallPublicIpAddressName = 'pip-${appEnvironment}-fw'
var firewallPublicIpAddressProperties = {
  name: firewallPublicIpAddressName
  publicIPAllocationMethod: 'Static'
  publicIPAddressVersion: 'IPv4'
  sku: 'Standard'
}
var firewallPrivateIpAddress = '10.101.0.4'
var firewallProperties = {
  name: firewallName
}

// Variables - Bastion
//////////////////////////////////////////////////
var bastionName = 'bastion-${appEnvironment}'
var bastionPublicIpAddressName = 'pip-${appEnvironment}-bastion'
var bastionPublicIpAddressProperties = {
  name: bastionPublicIpAddressName
  publicIPAllocationMethod: 'Static'
  publicIPAddressVersion: 'IPv4'
  sku: 'Standard'
}

// Variables - Private DNS
//////////////////////////////////////////////////
var appServicePrivateDnsZoneName = 'privatelink.azurewebsites.net'
var azureSqlPrivateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'

// Variables - Virtual Network Peering
//////////////////////////////////////////////////
var peeringProperties = {
  allowVirtualNetworkAccess: true
  allowForwardedTraffic: false
  allowGatewayTransit: false
  useRemoteGateways: false
}

// Variables - Network Security Group Flow Logs
//////////////////////////////////////////////////
var networkWatcherResourceGroupName = 'NetworkWatcherRG'

// Variables - Existing Resources
//////////////////////////////////////////////////
var eventHubNamespaceAuthorizationRuleName = 'RootManageSharedAccessKey'
var eventHubNamespaceName = 'evhns-${appEnvironment}-diagnostics'
var logAnalyticsWorkspaceName = 'log-${appEnvironment}'
var storageAccountName = replace('sa-diag-${uniqueString(subscription().subscriptionId)}', '-', '')

// Existing Resource - Event Hub Authorization Rule
//////////////////////////////////////////////////
resource eventHubNamespaceAuthorizationRule 'Microsoft.EventHub/namespaces/authorizationRules@2021-11-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: '${eventHubNamespaceName}/${eventHubNamespaceAuthorizationRuleName}'
}

// Existing Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: logAnalyticsWorkspaceName
}

// Existing Resource - Storage Account - Diagnostics
//////////////////////////////////////////////////
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: storageAccountName
}

// Module - Storage Account
//////////////////////////////////////////////////
module storageAccountModule 'storage_account.bicep' = {
  name: 'storageAccountDeployment'
  params: {
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    storageAccountProperties: nsgFlowLogsStorageAccountProperties
    storageAccountName: nsgFlowLogsStorageAccountName
    tags: tags
  }
}

// Module - Nat Gateway
//////////////////////////////////////////////////
module natGatewayModule './nat_gateway.bicep' = {
  name: 'natGatewayDeployment'
  params: {
    location: location
    natGatewayName: natGatewayName
    natGatewayProperties: natGatewayProperties
    publicIpPrefixName: publicIpPrefixName
    publicIpPrefixProperties: publicIpPrefixProperties
    tags: tags
  }
}

// Module - Network Security Group
//////////////////////////////////////////////////
module networkSecurityGroupModule './network_security_group.bicep' = {
  name: 'networkSecurityGroupsDeployment'
  params: {
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    networkSecurityGroups: networkSecurityGroups
    storageAccountId: storageAccount.id
    tags: tags
  }
}

// Module - Route Table
//////////////////////////////////////////////////
module routeTableModule './route_table.bicep' = {
  name: 'routeTableDeployment'
  params: {
    routes: routes
    routeTableName: routeTableName
    location: location
    tags: tags
  }
}

// Module - Virtual Network
//////////////////////////////////////////////////
module virtualNetworkModule 'virtual_network.bicep' = {
  name: 'virtualNetworkDeployment'
  params: {
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    hubVirtualNetworkName: hubVirtualNetworkName
    hubVirtualNetworkPrefix: hubVirtualNetworkPrefix
    hubVirtualNetworkSubnets: hubVirtualNetworkSubnets
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    spokeVirtualNetworkName: spokeVirtualNetworkName
    spokeVirtualNetworkPrefix: spokeVirtualNetworkPrefix
    spokeVirtualNetworkSubnets: spokeVirtualNetworkSubnets
    storageAccountId: storageAccount.id
    tags: tags
  }
}

// Module - Firewall
//////////////////////////////////////////////////
module firewallModule './firewall.bicep' = if (deployFirewall == true) {
  name: 'firewallDeployment'
  params: {
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    // firewallName: firewallName
    firewallProperties: firewallProperties
    firewallSubnetId: virtualNetworkModule.outputs.firewallSubnetId
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    // publicIpAddressName: firewallPublicIpAddressName
    publicIpAddressProperties: firewallPublicIpAddressProperties
    storageAccountId: storageAccount.id
    tags: tags
  }
}

// Module - Azure Bastion
//////////////////////////////////////////////////
module azureBastionModule './bastion.bicep' = {
  name: 'azureBastionDeployment'
  params: {
    bastionName: bastionName
    bastionSubnetId: virtualNetworkModule.outputs.bastionSubnetId
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    // publicIpAddressName: bastionPublicIpAddressName
    publicIpAddressProperties: bastionPublicIpAddressProperties
    storageAccountId: storageAccount.id
    tags: tags
  }
}

// Module - Virtual Network Peering
//////////////////////////////////////////////////
module vnetPeeringVgwModule 'virtual_network_peering.bicep' = {
  name: 'vnetPeeringVgwDeployment'
  params: {
    hubVirtualNetworkId: virtualNetworkModule.outputs.hubVirtualNetworkId
    hubVirtualNetworkName: hubVirtualNetworkName
    peeringProperties: peeringProperties
    spokeVirtualNetworkId: virtualNetworkModule.outputs.spokeVirtualNetworkId
    spokeVirtualNetworkName: spokeVirtualNetworkName
  }
}

// Module - Private Dns
//////////////////////////////////////////////////
module privateDnsModule './private_dns.bicep' = {
  name: 'privateDnsDeployment'
  params: {
    appServicePrivateDnsZoneName: appServicePrivateDnsZoneName
    azureSqlPrivateDnsZoneName: azureSqlPrivateDnsZoneName
    hubVirtualNetworkId: virtualNetworkModule.outputs.hubVirtualNetworkId
    hubVirtualNetworkName: hubVirtualNetworkName
    spokeVirtualNetworkId: virtualNetworkModule.outputs.spokeVirtualNetworkId
    spokeVirtualNetworkName: spokeVirtualNetworkName
    tags: tags
  }
}

// Module - Network Security Group Flow Logs
// //////////////////////////////////////////////////
module nsgFlowLogsModule './network_security_group_flow_logs.bicep' = {
  scope: resourceGroup(networkWatcherResourceGroupName)
  name: 'nsgFlowLogsDeployment'
  params: {
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    networkSecurityGroupProperties: networkSecurityGroupModule.outputs.networkSecurityGroupProperties
    storageAccountId: storageAccountModule.outputs.storageAccountId
  }
}
