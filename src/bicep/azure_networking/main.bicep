// Parameters
//////////////////////////////////////////////////
@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('Deploy Azure Firewall if value is set to true.')
param deployAzureFirewall bool = false

@description('The date of the resource deployment.')
param deploymentDate string = utcNow('yyyy-MM-dd')

@description('Deploy Azure VPN Gateway is value is set to true.')
param deployVpnGateway bool = false

@description('The address prefix of the on-premises network.')
param localNetworkGatewayAddressPrefix string

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of the Management Resource Group.')
param managementResourceGroupName string

@description('The name of the owner of the deployment.')
param ownerName string

@description('The name of the Security Resource Group.')
param securityResourceGroupName string

@description('The public IP address of the on-premises network.')
param sourceAddressPrefix string

// Variables
//////////////////////////////////////////////////
var appServicePrivateDnsZoneName = 'privatelink.azurewebsites.net'
var azureBastionName = 'bastion-${appEnvironment}-001'
var azureBastionPublicIpAddressName = 'pip-${appEnvironment}-bastion001'
var azureFirewallName = 'fw-${appEnvironment}-001'
var azureFirewallPublicIpAddressName = 'pip-${appEnvironment}-fw001'
var azureSqlPrivateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'
var connectionName = 'cn-${appEnvironment}-vgw001'
var internetRouteTableName = 'route-${appEnvironment}-internet'
var localNetworkGatewayName = 'lgw-${appEnvironment}-vgw001'
var natGatewayName = 'ngw-${appEnvironment}-001'
var natGatewayPublicIPPrefixName = 'pipp-${appEnvironment}-ngw001'
var networkWatcherResourceGroupName = 'NetworkWatcherRG'
var nsgFlowLogsStorageAccountName = replace('sa-${appEnvironment}-nsgflow', '-', '')
var tags = {
  deploymentDate: deploymentDate
  owner: ownerName
}
var virtualNetwork001Name = 'vnet-${appEnvironment}-001'
var virtualNetwork001Prefix = '10.101.0.0/16'
var virtualNetwork002Name = 'vnet-${appEnvironment}-002'
var virtualNetwork002Prefix = '10.102.0.0/16'
var vpnGatewayName = 'vpng-${appEnvironment}-001'
var vpnGatewayPublicIpAddressName = 'pip-${appEnvironment}-vgw001'

// Variable Arrays
//////////////////////////////////////////////////
var networkSecurityGroups = loadJsonContent('network_security_groups.json', 'networkSecurityGroups')
var virtualNetwork001Subnets = [
  {
    name: 'snet-${appEnvironment}-applicationGateway'
    properties: {
      addressPrefix: '10.101.11.0/24'
      networkSecurityGroup: {
        id: networkSecurityGroupsModule.outputs.networkSecurityGroupProperties[5].resourceId
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
        id: networkSecurityGroupsModule.outputs.networkSecurityGroupProperties[6].resourceId
      }
    }
  }
  {
    name: 'AzureFirewallSubnet'
    properties: {
      addressPrefix: '10.101.1.0/24'
    }
  }
  {
    name: 'GatewaySubnet'
    properties: {
      addressPrefix: '10.101.255.0/24'
    }
  }
  {
    name: 'snet-${appEnvironment}-management'
    properties: {
      addressPrefix: '10.101.31.0/24'
      networkSecurityGroup: {
        id: networkSecurityGroupsModule.outputs.networkSecurityGroupProperties[11].resourceId
      }
    }
  }
]
var virtualNetwork002Subnets = [
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
    name: 'snet-${appEnvironment}-adeAppSql'
    properties: {
      addressPrefix: '10.102.160.0/24'
      networkSecurityGroup: {
        id: networkSecurityGroupsModule.outputs.networkSecurityGroupProperties[0].resourceId
      }
      privateEndpointNetworkPolicies: 'Enabled'
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
        id: networkSecurityGroupsModule.outputs.networkSecurityGroupProperties[1].resourceId
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
        id: networkSecurityGroupsModule.outputs.networkSecurityGroupProperties[2].resourceId
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
        id: networkSecurityGroupsModule.outputs.networkSecurityGroupProperties[3].resourceId
      }
      serviceEndpoints: [
        {
          service: 'Microsoft.Sql'
        }
      ]
    }
  }
  {
    name: 'snet-${appEnvironment}-adeWeb-vm'
    properties: {
      addressPrefix: '10.102.1.0/24'
      natGateway: {
        id: natGatewayModule.outputs.natGatewayId
      }
      networkSecurityGroup: {
        id: networkSecurityGroupsModule.outputs.networkSecurityGroupProperties[4].resourceId
      }
      serviceEndpoints: [
        {
          service: 'Microsoft.Sql'
        }
      ]
    }
  }
  {
    name: 'snet-${appEnvironment}-dataIngestorService'
    properties: {
      addressPrefix: '10.102.152.0/24'
      networkSecurityGroup: {
        id: networkSecurityGroupsModule.outputs.networkSecurityGroupProperties[7].resourceId
      }
      privateEndpointNetworkPolicies: 'Enabled'
    }
  }
  {
    name: 'snet-${appEnvironment}-dataReporterService'
    properties: {
      addressPrefix: '10.102.153.0/24'
      networkSecurityGroup: {
        id: networkSecurityGroupsModule.outputs.networkSecurityGroupProperties[8].resourceId
      }
      privateEndpointNetworkPolicies: 'Enabled'
    }
  }
  {
    name: 'snet-${appEnvironment}-eventIngestorService'
    properties: {
      addressPrefix: '10.102.154.0/24'
      networkSecurityGroup: {
        id: networkSecurityGroupsModule.outputs.networkSecurityGroupProperties[9].resourceId
      }
      privateEndpointNetworkPolicies: 'Enabled'
    }
  }
  {
    name: 'snet-${appEnvironment}-inspectorGadgetSql'
    properties: {
      addressPrefix: '10.102.161.0/24'
      networkSecurityGroup: {
        id: networkSecurityGroupsModule.outputs.networkSecurityGroupProperties[10].resourceId
      }
      privateEndpointNetworkPolicies: 'Enabled'
    }
  }
  {
    name: 'snet-${appEnvironment}-userService'
    properties: {
      addressPrefix: '10.102.151.0/24'
      networkSecurityGroup: {
        id: networkSecurityGroupsModule.outputs.networkSecurityGroupProperties[12].resourceId
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
        id: networkSecurityGroupsModule.outputs.networkSecurityGroupProperties[13].resourceId
      }
      privateEndpointNetworkPolicies: 'Enabled'
    }
  }
]

// Existing Resource - Event Hub Authorization Rule
//////////////////////////////////////////////////
resource eventHubNamespaceAuthorizationRule 'Microsoft.EventHub/namespaces/authorizationRules@2021-11-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: 'evh-${appEnvironment}-diagnostics/RootManageSharedAccessKey'
}

// Existing Resource - Key Vault
//////////////////////////////////////////////////
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  scope: resourceGroup(securityResourceGroupName)
  name: 'kv-${appEnvironment}-001'
}

// Existing Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: 'log-${appEnvironment}-001'
}

// Existing Resource - Storage Account - Diagnostics
//////////////////////////////////////////////////
resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: replace('sa-${appEnvironment}-diags', '-', '')
}

// Module - Storage Account - Nsg Flow Logs
//////////////////////////////////////////////////
module storageAccountNsgFlowLogsModule './storage_account.bicep' = {
  name: 'storageAccountNsgFlowLogsDeployment'
  params: {
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
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
    natGatewayPublicIPPrefixName: natGatewayPublicIPPrefixName
    tags: tags
  }
}

// Module - Network Security Group
//////////////////////////////////////////////////
module networkSecurityGroupsModule './network_security_group.bicep' = {
  name: 'networkSecurityGroupsDeployment'
  params: {
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    networkSecurityGroups: networkSecurityGroups
    tags: tags
  }
}

// Module - Route Table
//////////////////////////////////////////////////
module routeTableModule './route_table.bicep' = {
  name: 'routeTableDeployment'
  params: {
    internetRouteTableName: internetRouteTableName
    location: location
    tags: tags
  }
}

// Module - Virtual Network
//////////////////////////////////////////////////
module virtualNetworkModule 'virtual_network.bicep' = {
  name: 'virtualNetworkDeployment'
  params: {
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    tags: tags
    virtualNetwork001Name: virtualNetwork001Name
    virtualNetwork001Prefix: virtualNetwork001Prefix
    virtualNetwork001Subnets: virtualNetwork001Subnets
    virtualNetwork002Name: virtualNetwork002Name
    virtualNetwork002Prefix: virtualNetwork002Prefix
    virtualNetwork002Subnets: virtualNetwork002Subnets
  }
}

// Module - Azure Firewall
//////////////////////////////////////////////////
module azureFirewallModule './firewall.bicep' = if (deployAzureFirewall == true) {
  name: 'azureFirewallDeployment'
  params: {
    azureFirewallName: azureFirewallName
    azureFirewallPublicIpAddressName: azureFirewallPublicIpAddressName
    azureFirewallSubnetId: virtualNetworkModule.outputs.azureFirewallSubnetId
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    tags: tags
  }
}

// Module - Azure Bastion
//////////////////////////////////////////////////
module azureBastionModule './bastion.bicep' = {
  name: 'azureBastionDeployment'
  params: {
    azureBastionName: azureBastionName
    azureBastionPublicIpAddressName: azureBastionPublicIpAddressName
    azureBastionSubnetId: virtualNetworkModule.outputs.azureBastionSubnetId
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    tags: tags
  }
}

// Module - Azure Vpn Gateway
//////////////////////////////////////////////////
module azureVpnGatewayModule './vpn_gateway.bicep' = if (deployVpnGateway == true) {
  name: 'vpnGatewayDeployment'
  params: {
    connectionName: connectionName
    connectionSharedKey: keyVault.getSecret('resourcePassword')
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    gatewaySubnetId: virtualNetworkModule.outputs.gatewaySubnetId
    localNetworkGatewayAddressPrefix: localNetworkGatewayAddressPrefix
    localNetworkGatewayName: localNetworkGatewayName
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    sourceAddressPrefix: sourceAddressPrefix
    tags: tags
    vpnGatewayName: vpnGatewayName
    vpnGatewayPublicIpAddressName: vpnGatewayPublicIpAddressName
  }
}

// Module - Virtual Network Peering (deployVpnGateway == true)
//////////////////////////////////////////////////
module vnetPeeringVgwModule './vnet_peering_vgw.bicep' = if (deployVpnGateway == true) {
  name: 'vnetPeeringVgwDeployment'
  params: {
    virtualNetwork001Id: virtualNetworkModule.outputs.virtualNetwork001Id
    virtualNetwork001Name: virtualNetwork001Name
    virtualNetwork002Id: virtualNetworkModule.outputs.virtualNetwork002Id
    virtualNetwork002Name: virtualNetwork002Name
  }
}

// Module - Virtual Network Peering (deployVpnGateway == false)
//////////////////////////////////////////////////
module vnetPeeringNoVgwModule './vnet_peering_no_vgw.bicep' = if (deployVpnGateway == false) {
  name: 'vnetPeeringNoVgwDeployment'
  params: {
    virtualNetwork001Id: virtualNetworkModule.outputs.virtualNetwork001Id
    virtualNetwork001Name: virtualNetwork001Name
    virtualNetwork002Id: virtualNetworkModule.outputs.virtualNetwork002Id
    virtualNetwork002Name: virtualNetwork002Name
  }
}

// Module - Private Dns
//////////////////////////////////////////////////
module privateDnsModule './private_dns.bicep' = {
  name: 'privateDnsDeployment'
  params: {
    appServicePrivateDnsZoneName: appServicePrivateDnsZoneName
    azureSqlPrivateDnsZoneName: azureSqlPrivateDnsZoneName
    virtualNetwork001Id: virtualNetworkModule.outputs.virtualNetwork001Id
    virtualNetwork001Name: virtualNetwork001Name
    virtualNetwork002Id: virtualNetworkModule.outputs.virtualNetwork002Id
    virtualNetwork002Name: virtualNetwork002Name
    tags: tags
  }
}

// Module - Network Security Group Flow Logs
//////////////////////////////////////////////////
module nsgFlowLogsModule './network_security_group_flow_logs.bicep' = {
  scope: resourceGroup(networkWatcherResourceGroupName)
  name: 'nsgFlowLogsDeployment'
  params: {
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    networkSecurityGroupProperties: networkSecurityGroupsModule.outputs.networkSecurityGroupProperties
    nsgFlowLogsStorageAccountId: storageAccountNsgFlowLogsModule.outputs.storageAccountId
  }
}
