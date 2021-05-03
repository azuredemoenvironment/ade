// target scope
targetScope = 'subscription'

// parameters
param defaultPrimaryRegion string
param aliasRegion string
param sourceAddressPrefix string
param monitorResourceGroupName string
param networkingResourceGroupName string
param localNetworkGatewayAddressPrefix string
param connectionSharedKey string
param deployAzureFirewall bool = false
param deployVpnGateway bool = false

// existing resources
// variables - log analytics workspace
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
// variables - storage account - nsg flow logs
var nsgFlowLogsStorageAccountName = replace('saade${aliasRegion}nsgflow', '-', '')

// module - nat gateway
// variables
var natGatewayPublicIPPrefixName = 'pipp-ade-${aliasRegion}-ngw001'
var natGatewayName = 'ngw-ade-${aliasRegion}-001'
// module deployment
module natGatewayModule './azure_nat_gateway.bicep' = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'natGatewayDeployment'
  params: {
    location: defaultPrimaryRegion
    natGatewayPublicIPPrefixName: natGatewayPublicIPPrefixName
    natGatewayName: natGatewayName
  }
}

// module - network security group
// variables
var azureBastionSubnetNSGName = 'nsg-ade-${aliasRegion}-bastion'
var managementSubnetNSGName = 'nsg-ade-${aliasRegion}-management'
var nTierWebSubnetNSGName = 'nsg-ade-${aliasRegion}-ntierweb'
var nTierAppSubnetNSGName = 'nsg-ade-${aliasRegion}-ntierapp'
var vmssSubnetNSGName = 'nsg-ade-${aliasRegion}-vmss'
var clientServicesSubnetNSGName = 'nsg-ade-${aliasRegion}-clientservices'
// module deployment
module networkSecurityGroupsModule './azure_network_security_group.bicep' = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'networkSecurityGroupsDeployment'
  params: {
    location: defaultPrimaryRegion
    monitorResourceGroupName: monitorResourceGroupName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    sourceAddressPrefix: sourceAddressPrefix
    azureBastionSubnetNSGName: azureBastionSubnetNSGName
    managementSubnetNSGName: managementSubnetNSGName
    nTierWebSubnetNSGName: nTierWebSubnetNSGName
    nTierAppSubnetNSGName: nTierAppSubnetNSGName
    vmssSubnetNSGName: vmssSubnetNSGName
    clientServicesSubnetNSGName: clientServicesSubnetNSGName
  }
}

// module - route table
// variables
var internetRouteTableName = 'route-ade-${aliasRegion}-internet'
// module deployment
module routeTableModule './azure_route_table.bicep' = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'routeTableDeployment'
  params: {
    location: defaultPrimaryRegion
    internetRouteTableName: internetRouteTableName
  }
}

// module - virtual network - virtual network 001
// variables
var virtualNetwork001Name = 'vnet-ade-${aliasRegion}-001'
var virtualnetwork001Prefix = '10.101.0.0/16'
var azureFirewallSubnetName = 'AzureFirewallSubnet'
var azureFirewallSubnetPrefix = '10.101.1.0/24'
var applicationGatewaySubnetName = 'snet-agw'
var applicationGatewaySubnetPrefix = '10.101.11.0/24'
var azureBastionSubnetName = 'AzureBastionSubnet'
var azureBastionSubnetPrefix = '10.101.21.0/24'
var managementSubnetName = 'snet-management'
var managementSubnetPrefix = '10.101.31.0/24'
var gatewaySubnetName = 'GatewaySubnet'
var gatewaySubnetPrefix = '10.101.255.0/24'
// module deployment
module virtualNetwork001Module './azure_virtual_network_001.bicep' = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'virtualNetwork001Deployment'
  params: {
    location: defaultPrimaryRegion
    monitorResourceGroupName: monitorResourceGroupName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    virtualNetwork001Name: virtualNetwork001Name
    virtualnetwork001Prefix: virtualnetwork001Prefix
    azureFirewallSubnetName: azureFirewallSubnetName
    azureFirewallSubnetPrefix: azureFirewallSubnetPrefix
    applicationGatewaySubnetName: applicationGatewaySubnetName
    applicationGatewaySubnetPrefix: applicationGatewaySubnetPrefix
    azureBastionSubnetName: azureBastionSubnetName
    azureBastionSubnetPrefix: azureBastionSubnetPrefix
    managementSubnetName: managementSubnetName
    managementSubnetPrefix: managementSubnetPrefix
    gatewaySubnetName: gatewaySubnetName
    gatewaySubnetPrefix: gatewaySubnetPrefix
    azureBastionSubnetNSGId: networkSecurityGroupsModule.outputs.azureBastionSubnetNSGId
    managementSubnetNSGId: networkSecurityGroupsModule.outputs.managementSubnetNSGId
  }
}

// module - virtual network - virtual network 002
// variables
var virtualNetwork002Name = 'vnet-ade-${aliasRegion}-002'
var virtualnetwork002Prefix = '10.102.0.0/16'
var nTierWebSubnetName = 'snet-nTierWeb'
var nTierWebSubnetPrefix = '10.102.1.0/24'
var nTierAppSubnetName = 'snet-nTierApp'
var nTierAppSubnetPrefix = '10.102.2.0/24'
var vmssSubnetName = 'snet-vmss'
var vmssSubnetPrefix = '10.102.11.0/24'
var clientServicesSubnetName = 'snet-clientServices'
var clientServicesSubnetPrefix = '10.102.21.0/24'
var vnetIntegrationSubnetName = 'snet-vnetIntegration'
var vnetIntegrationSubnetPrefix = '10.102.101.0/24'
var privateEndpointSubnetName = 'snet-privateEndpoint'
var privateEndpointSubnetPrefix = '10.102.102.0/24'
var aksSubnetName = 'snet-aks'
var aksSubnetPrefix = '10.102.201.0/24'
// module deployment
module virtualNetwork002Module './azure_virtual_network_002.bicep' = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'virtualNetwork002Deployment'
  params: {
    location: defaultPrimaryRegion
    monitorResourceGroupName: monitorResourceGroupName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    virtualNetwork002Name: virtualNetwork002Name
    virtualnetwork002Prefix: virtualnetwork002Prefix
    nTierWebSubnetName: nTierWebSubnetName
    nTierWebSubnetPrefix: nTierWebSubnetPrefix
    nTierAppSubnetName: nTierAppSubnetName
    nTierAppSubnetPrefix: nTierAppSubnetPrefix
    vmssSubnetName: vmssSubnetName
    vmssSubnetPrefix: vmssSubnetPrefix
    clientServicesSubnetName: clientServicesSubnetName
    clientServicesSubnetPrefix: clientServicesSubnetPrefix
    vnetIntegrationSubnetName: vnetIntegrationSubnetName
    vnetIntegrationSubnetPrefix: vnetIntegrationSubnetPrefix
    privateEndpointSubnetName: privateEndpointSubnetName
    privateEndpointSubnetPrefix: privateEndpointSubnetPrefix
    aksSubnetName: aksSubnetName
    aksSubnetPrefix: aksSubnetPrefix
    nTierWebSubnetNSGId: networkSecurityGroupsModule.outputs.nTierWebSubnetNSGId
    nTierAppSubnetNSGId: networkSecurityGroupsModule.outputs.nTierAppSubnetNSGId
    vmssSubnetNSGId: networkSecurityGroupsModule.outputs.vmssSubnetNSGId
    clientServicesSubnetNSGId: networkSecurityGroupsModule.outputs.clientServicesSubnetNSGId
    natGatewayId: natGatewayModule.outputs.natGatewayId
    internetRouteTableId: routeTableModule.outputs.internetRouteTableId
  }
}

// module - azure firewall
// variables
var azureFirewallPublicIpAddressName = 'pip-ade-${aliasRegion}-fw001'
var azureFirewallName = 'fw-ade-${aliasRegion}-001'
// module deployment
module azureFirewallModule './azure_firewall.bicep' = if (deployAzureFirewall == true) {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'azureFirewallDeployment'
  params: {
    location: defaultPrimaryRegion
    monitorResourceGroupName: monitorResourceGroupName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    networkingResourceGroupName: networkingResourceGroupName
    virtualNetwork001Name: virtualNetwork001Name
    azureFirewallPublicIpAddressName: azureFirewallPublicIpAddressName
    azureFirewallName: azureFirewallName
    azureFirewallSubnetId: virtualNetwork001Module.outputs.azureFirewallSubnetId
  }
}

// module - azure bastion
// variables
var azureBastionPublicIpAddressName = 'pip-ade-${aliasRegion}-bastion001'
var azureBastionName = 'bastion-ade-${aliasRegion}-001'
// module deployment
module azureBastionModule './azure_bastion.bicep' = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'azureBastionDeployment'
  params: {
    location: defaultPrimaryRegion
    monitorResourceGroupName: monitorResourceGroupName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    networkingResourceGroupName: networkingResourceGroupName
    virtualNetwork001Name: virtualNetwork001Name
    azureBastionPublicIpAddressName: azureBastionPublicIpAddressName
    azureBastionName: azureBastionName
    azureBastionSubnetId: virtualNetwork001Module.outputs.azureBastionSubnetId
  }
}

// module - azure vpn gateway
// variables
var vpnGatewayPublicIpAddressName = 'pip-ade-${aliasRegion}-vgw001'
var localNetworkGatewayName = 'lgw-ade-${aliasRegion}-vgw001'
var vpnGatewayName = 'vgw-ade-${aliasRegion}-001'
var connectionName = 'cn-ade-${aliasRegion}-vgw001'
// module deployment
module azureVpnGatewayModule './azure_vpn_gateway.bicep' = if (deployVpnGateway == true) {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'vpnGatewayDeployment'
  params: {
    location: defaultPrimaryRegion
    sourceAddressPrefix: sourceAddressPrefix
    localNetworkGatewayAddressPrefix: localNetworkGatewayAddressPrefix
    connectionSharedKey: connectionSharedKey
    monitorResourceGroupName: monitorResourceGroupName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    networkingResourceGroupName: networkingResourceGroupName
    virtualNetwork001Name: virtualNetwork001Name
    vpnGatewayPublicIpAddressName: vpnGatewayPublicIpAddressName
    localNetworkGatewayName: localNetworkGatewayName
    vpnGatewayName: vpnGatewayName
    connectionName: connectionName
    gatewaySubnetId: virtualNetwork001Module.outputs.gatewaySubnetId
  }
}

// module - virtual network peering (with vpn gateway)
// module deployment
module vnetPeeringVgwModule './azure_vnet_peering_vgw.bicep' = if (deployVpnGateway == true) {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'vnetPeeringVgwDeployment'
  params: {
    networkingResourceGroupName: networkingResourceGroupName
    virtualNetwork001Name: virtualNetwork001Name
    virtualNetwork002Name: virtualNetwork002Name
    virtualNetwork001Id: virtualNetwork001Module.outputs.virtualNetwork001Id
    virtualNetwork002Id: virtualNetwork002Module.outputs.virtualNetwork002Id
  }
}

// module - virtual network peering (without vpn gateway)
// module deployment
module vnetPeeringNoVgwModule './azure_vnet_peering_no_vgw.bicep' = if (deployVpnGateway == false) {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'vnetPeeringNoVgwDeployment'
  params: {
    networkingResourceGroupName: networkingResourceGroupName
    virtualNetwork001Name: virtualNetwork001Name
    virtualNetwork002Name: virtualNetwork002Name
    virtualNetwork001Id: virtualNetwork001Module.outputs.virtualNetwork001Id
    virtualNetwork002Id: virtualNetwork002Module.outputs.virtualNetwork002Id
  }
}

// module - private dns
// variables
var appServicePrivateDnsZoneName = 'privatelink.azurewebsites.net'
var azureSQLprivateDnsZoneName = 'privatelink.database.windows.net'
// module deployment
module privateDnsModule './azure_private_dns.bicep' = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'privateDnsDeployment'
  params: {
    location: defaultPrimaryRegion
    networkingResourceGroupName: networkingResourceGroupName
    virtualNetwork001Name: virtualNetwork001Name
    virtualNetwork002Name: virtualNetwork002Name
    appServicePrivateDnsZoneName: appServicePrivateDnsZoneName
    azureSQLPrivateDnsZoneName: azureSQLprivateDnsZoneName
    virtualNetwork001Id: virtualNetwork001Module.outputs.virtualNetwork001Id
    virtualNetwork002Id: virtualNetwork002Module.outputs.virtualNetwork002Id
  }
}

// module - network security group flow logs
// variables
var networkWatcherResourceGroupName = 'NetworkWatcherRG'
// module deployment
module nsgFlowLogsModule './azure_network_security_group_flow_logs.bicep' = {
  scope: resourceGroup(networkWatcherResourceGroupName)
  name: 'nsgFlowLogsDeployment'
  params: {
    location: defaultPrimaryRegion
    monitorResourceGroupName: monitorResourceGroupName
    nsgFlowLogsStorageAccountName: nsgFlowLogsStorageAccountName
    azureBastionSubnetNSGId: networkSecurityGroupsModule.outputs.azureBastionSubnetNSGId
    managementSubnetNSGId: networkSecurityGroupsModule.outputs.managementSubnetNSGId
    nTierWebSubnetNSGId: networkSecurityGroupsModule.outputs.nTierWebSubnetNSGId
    nTierAppSubnetNSGId: networkSecurityGroupsModule.outputs.nTierAppSubnetNSGId
    vmssSubnetNSGId: networkSecurityGroupsModule.outputs.vmssSubnetNSGId
    clientServicesSubnetNSGId: networkSecurityGroupsModule.outputs.clientServicesSubnetNSGId
  }
}
