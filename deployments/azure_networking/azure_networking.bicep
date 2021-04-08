// parameters
param location string = resourceGroup().location
param aliasRegion string
param sourceAddressPrefix string
param localNetworkGatewayAddressPrefix string
param connectionSharedKey string
param deployAzureFirewall bool = false
param deployVpnGateway bool = false

// variables - existing resources - log analytics
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'

// variables - nat gateway
var natGatewayPublicIPPrefixName = 'pipp-ade-${aliasRegion}-ngw001'
var natGatewayName = 'ngw-ade-${aliasRegion}-001'

// variables - network security group
var azureBastionSubnetNSGName = 'nsg-ade-${aliasRegion}-azurebastion'
var managementSubnetNSGName = 'nsg-ade-${aliasRegion}-management'
var nTierWebSubnetNSGName = 'nsg-ade-${aliasRegion}-ntierweb'
var nTierAppSubnetNSGName = 'nsg-ade-${aliasRegion}-ntierapp'
var nTierDBSubnetNSGName = 'nsg-ade-${aliasRegion}-ntierdb'
var vmssSubnetNSGName = 'nsg-ade-${aliasRegion}-vmss'
var clientServicesSubnetNSGName = 'nsg-ade-${aliasRegion}-clientservices'

// variables - route table
var internetRouteTableName = 'route-ade-${aliasRegion}-internet'

// variables - virtual network resource group
var networkingResourceGroupName = 'rg-ade=${aliasRegion}-networking'

// variables - virtual network 001
var virtualNetwork001Name = 'vnet-ade-${aliasRegion}-001'
var virtualnetwork001Prefix = '10.101.0.0/16'
var azureFirewallSubnetName = 'AzureFirewallSubnet'
var azureFirewallSubnetPrefix = '10.101.1.0/24'
var applicationgatewaySubnetName = 'ApplicationGatewaySubnet'
var applicationgatewaySubnetPrefix = '10.101.11.0/24'
var azureBastionSubnetName = 'AzureBastionSubnet'
var azureBastionSubnetPrefix = '10.101.21.0/24'
var managementSubnetName = 'management'
var managementSubnetPrefix = '10.101.31.0/24'
var gatewaySubnetName = 'GatewaySubnet'
var gatewaySubnetPrefix = '10.101.255.0/24'

// variables - virtual network 002
var virtualNetwork002Name = 'vnet-ade-${aliasRegion}-002'
var virtualnetwork002Prefix = '10.102.0.0/16'
var nTierWebSubnetName = 'nTierWeb'
var nTierWebSubnetPrefix = '10.102.1.0/24'
var nTierAppSubnetName = 'nTierApp'
var nTierAppSubnetPrefix = '10.102.2.0/24'
var nTierDBSubnetName = 'nTierDB'
var nTierDBSubnetPrefix = '10.102.3.0/24'
var vmssSubnetName = 'vmss'
var vmssSubnetPrefix = '10.102.11.0/24'
var clientServicesSubnetName = 'clientServices'
var clientServicesSubnetPrefix = '10.102.21.0/24'
var vnetIntegrationSubnetName = 'vnetIntegration'
var vnetIntegrationSubnetPrefix = '10.102.101.0/24'
var privateEndpointSubnetName = 'privateEndpoint'
var privateEndpointSubnetPrefix = '10.102.102.0/24'
var aksSubnetName = 'aks'
var aksSubnetPrefix = '10.102.201.0/24'

// variables - azure firewall
var azureFirewallPublicIpAddressName = 'pip-ade-${aliasRegion}-fw001'
var azureFirewallName = 'fw-ade-${aliasRegion}-001'

// variables - azure bastion
var azureBastionPublicIpAddressName = 'pip-ade-${aliasRegion}-bastion001'
var azureBastionName = 'bastion-ade-${aliasRegion}-001'

// variables - vpn gateway
var vpnGatewayPublicIpAddressName = 'pip-ade-${aliasRegion}-vgw001'
var localNetworkGatewayName = 'lgw-ade-${aliasRegion}-vgw001'
var vpnGatewayName = 'vgw-ade-${aliasRegion}-001'
var connectionName = 'cn-ade-${aliasRegion}-vgw001'

// variables - private dns
var appServicePrivateDnsZoneName = 'privatelink.azurewebsites.net'
var azureSQLprivateDnsZoneName = 'privatelink.database.windows.net'

// module - nat gateway
module natGatewayModule './azure_nat_gateway.bicep' = {
  name: 'natGatewayDeployment'
  params: {
    location: location
    natGatewayPublicIPPrefixName: natGatewayPublicIPPrefixName
    natGatewayName: natGatewayName
  }
}

// module - network security group
module networkSecurityGroupsModule './azure_network_security_group.bicep' = {
  name: 'networkSecurityGroupsDeployment'
  params: {
    location: location
    monitorResourceGroupName: monitorResourceGroupName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    sourceAddressPrefix: sourceAddressPrefix
    azureBastionSubnetNSGName: azureBastionSubnetNSGName
    managementSubnetNSGName: managementSubnetNSGName
    nTierWebSubnetNSGName: nTierWebSubnetNSGName
    nTierAppSubnetNSGName: nTierAppSubnetNSGName
    nTierDBSubnetNSGName: nTierDBSubnetNSGName
    vmssSubnetNSGName: vmssSubnetNSGName
    clientServicesSubnetNSGName: clientServicesSubnetNSGName
  }
}

// module - route table
module routeTableModule './azure_route_table.bicep' = {
  name: 'routeTableDeployment'
  params: {
    location: location
    internetRouteTableName: internetRouteTableName
  }
}

// module - virtual network 001
module virtualNetwork001Module './azure_virtual_network_001.bicep' = {
  name: 'virtualNetwork001Deployment'
  params: {
    location: location
    monitorResourceGroupName: monitorResourceGroupName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    virtualNetwork001Name: virtualNetwork001Name
    virtualnetwork001Prefix: virtualnetwork001Prefix
    azureFirewallSubnetName: azureFirewallSubnetName
    azureFirewallSubnetPrefix: azureFirewallSubnetPrefix
    applicationgatewaySubnetName: applicationgatewaySubnetName
    applicationgatewaySubnetPrefix: applicationgatewaySubnetPrefix
    azureBastionSubnetName: azureBastionSubnetName
    azureBastionSubnetPrefix: azureBastionSubnetPrefix
    managementSubnetName: managementSubnetName
    managementSubnetPrefix: managementSubnetPrefix
    gatewaySubnetName: gatewaySubnetName
    gatewaySubnetPrefix: gatewaySubnetPrefix
    azureBastionSubnetNSGId: networkSecurityGroupsModule.outputs.azureBastionSubnetNSGId
    managementSubnetNSGId: networkSecurityGroupsModule.outputs.managementSubnetNSGId
    natGatewayId: natGatewayModule.outputs.natGatewayId
  }
}

// module - virtual network 002
module virtualNetwork002Module './azure_virtual_network_002.bicep' = {
  name: 'virtualNetwork002Deployment'
  params: {
    location: location
    monitorResourceGroupName: monitorResourceGroupName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    virtualNetwork002Name: virtualNetwork002Name
    virtualnetwork002Prefix: virtualnetwork002Prefix
    nTierWebSubnetName: nTierWebSubnetName
    nTierWebSubnetPrefix: nTierWebSubnetPrefix
    nTierAppSubnetName: nTierAppSubnetName
    nTierAppSubnetPrefix: nTierAppSubnetPrefix
    nTierDBSubnetName: nTierDBSubnetName
    nTierDBSubnetPrefix: nTierDBSubnetPrefix
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
    nTierDBSubnetNSGId: networkSecurityGroupsModule.outputs.nTierDBSubnetNSGId
    vmssSubnetNSGId: networkSecurityGroupsModule.outputs.vmssSubnetNSGId
    clientServicesSubnetNSGId: networkSecurityGroupsModule.outputs.clientServicesSubnetNSGId
    internetRouteTableId: routeTableModule.outputs.internetRouteTableId
  }
}

// module - azure firewall
module azureFirewallModule './azure_firewall.bicep' = if (deployAzureFirewall == true) {
  name: 'azureFirewallDeployment'
  params: {
    location: location
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
module azureBastionModule './azure_bastion.bicep' = {
  name: 'azureBastionDeployment'
  params: {
    location: location
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
module azureVpnGatewayModule './azure_vpn_gateway.bicep' = if (deployVpnGateway == true) {
  name: 'vpnGatewayDeployment'
  params: {
    location: location
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

// module - private dns
module privateDnsModule './azure_private_dns.bicep' = {
  name: 'privateDnsDeployment'
  params: {
    location: location
    networkingResourceGroupName: networkingResourceGroupName
    virtualNetwork001Name: virtualNetwork001Name
    virtualNetwork002Name: virtualNetwork002Name
    appServicePrivateDnsZoneName: appServicePrivateDnsZoneName
    azureSQLPrivateDnsZoneName: azureSQLprivateDnsZoneName
    virtualNetwork001Id: virtualNetwork001Module.outputs.virtualNetwork001Id
    virtualNetwork002Id: virtualNetwork002Module.outputs.virtualNetwork002Id
  }
}

// module - virtual network peering (with vpn gateway)
module vnetPeeringVgwModule './azure_vnet_peering_vgw.bicep' = if (deployVpnGateway == true) {
  name: 'vnetPeeringVgwDeployment'
  params: {
    networkingResourceGroupName: networkingResourceGroupName
    virtualNetwork001Name: virtualNetwork001Name
    virtualNetwork002Name: virtualNetwork002Name
  }
}

// module - virtual network peering (without vpn gateway)
module vnetPeeringNoVgwModule './azure_vnet_peering_no_vgw.bicep' = if (deployVpnGateway == false) {
  name: 'vnetPeeringNoVgwDeployment'
  params: {
    networkingResourceGroupName: networkingResourceGroupName
    virtualNetwork001Name: virtualNetwork001Name
    virtualNetwork002Name: virtualNetwork002Name
    virtualNetwork001Id: virtualNetwork001Module.outputs.virtualNetwork001Id
    virtualNetwork002Id: virtualNetwork002Module.outputs.virtualNetwork002Id
  }
}
