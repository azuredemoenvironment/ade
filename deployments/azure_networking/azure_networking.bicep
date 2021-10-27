// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'

// Parameters
//////////////////////////////////////////////////
@description('The user alias and Azure region defined from user input.')
param aliasRegion string

@description('The selected Azure region for deployment.')
param azureRegion string

@description('Deploy Azure Firewall if value is set to true.')
param deployAzureFirewall bool = false

@description('Deploy Azure VPN Gateway is value is set to true.')
param deployVpnGateway bool = false

@description('The address prefix of the on-premises network.')
param localNetworkGatewayAddressPrefix string

@description('The public IP address of the on-premises network.')
param sourceAddressPrefix string

// Global Variables
//////////////////////////////////////////////////
// Resource Groups
var keyVaultResourceGroupName = 'rg-ade-${aliasRegion}-keyvault'
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
var networkingResourceGroupName = 'rg-ade-${aliasRegion}-networking'
// Resources
var adeAppAksSubnetName = 'snet-ade-${aliasRegion}-adeapp-aks'
var adeAppAksSubnetPrefix = '10.102.101.0/24'
var adeAppVmssSubnetName = 'snet-ade-${aliasRegion}-adeapp-vmss'
var adeAppVmssSubnetNSGName = 'nsg-ade-${aliasRegion}-adeapp-vmss'
var adeAppVmssSubnetPrefix = '10.102.12.0/24'
var adeAppVmSubnetName = 'snet-ade-${aliasRegion}-adeapp-vm'
var adeAppVmSubnetNSGName = 'nsg-ade-${aliasRegion}-adeapp-vm'
var adeAppVmSubnetPrefix = '10.102.2.0/24'
var adeWebVmssSubnetName = 'snet-ade-${aliasRegion}-adeweb-vmss'
var adeWebVmssSubnetNSGName = 'nsg-ade-${aliasRegion}-adeweb-vmss'
var adeWebVmssSubnetPrefix = '10.102.11.0/24'
var adeWebVmSubnetName = 'snet-ade-${aliasRegion}-adeweb-vm'
var adeWebVmSubnetNSGName = 'nsg-ade-${aliasRegion}-adeweb-vm'
var adeWebVmSubnetPrefix = '10.102.1.0/24'
var applicationGatewaySubnetName = 'snet-ade-${aliasRegion}-applicationGateway'
var applicationGatewaySubnetPrefix = '10.101.11.0/24'
var appServicePrivateDnsZoneName = 'privatelink.azurewebsites.net'
var azureBastionName = 'bastion-ade-${aliasRegion}-001'
var azureBastionPublicIpAddressName = 'pip-ade-${aliasRegion}-bastion001'
var azureBastionSubnetName = 'AzureBastionSubnet'
var azureBastionSubnetNSGName = 'nsg-ade-${aliasRegion}-bastion'
var azureBastionSubnetPrefix = '10.101.21.0/24'
var azureFirewallName = 'fw-ade-${aliasRegion}-001'
var azureFirewallPublicIpAddressName = 'pip-ade-${aliasRegion}-fw001'
var azureFirewallSubnetName = 'AzureFirewallSubnet'
var azureFirewallSubnetPrefix = '10.101.1.0/24'
var azureSQLprivateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'
var connectionName = 'cn-ade-${aliasRegion}-vgw001'
var gatewaySubnetName = 'GatewaySubnet'
var gatewaySubnetPrefix = '10.101.255.0/24'
var internetRouteTableName = 'route-ade-${aliasRegion}-internet'
var keyVaultName = 'kv-ade-${aliasRegion}-001'
var localNetworkGatewayName = 'lgw-ade-${aliasRegion}-vgw001'
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
var managementSubnetName = 'snet-ade-${aliasRegion}-management'
var managementSubnetNSGName = 'nsg-ade-${aliasRegion}-management'
var managementSubnetPrefix = '10.101.31.0/24'
var natGatewayName = 'ngw-ade-${aliasRegion}-001'
var natGatewayPublicIPPrefixName = 'pipp-ade-${aliasRegion}-ngw001'
var networkWatcherResourceGroupName = 'NetworkWatcherRG'
var nsgFlowLogsStorageAccountName = replace('saade${aliasRegion}nsgflow', '-', '')
var privateEndpointSubnetName = 'snet-ade-${aliasRegion}-privateEndpoint'
var privateEndpointSubnetPrefix = '10.102.102.0/24'
var virtualNetwork001Name = 'vnet-ade-${aliasRegion}-001'
var virtualnetwork001Prefix = '10.101.0.0/16'
var virtualNetwork002Name = 'vnet-ade-${aliasRegion}-002'
var virtualnetwork002Prefix = '10.102.0.0/16'
var vnetIntegrationSubnetName = 'snet-ade-${aliasRegion}-vnetintegration'
var vnetIntegrationSubnetPrefix = '10.102.201.0/24'
var vpnGatewayName = 'vpng-ade-${aliasRegion}-001'
var vpnGatewayPublicIpAddressName = 'pip-ade-${aliasRegion}-vgw001'

// Existing Resource - Key Vault
//////////////////////////////////////////////////
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  scope: resourceGroup(keyVaultResourceGroupName)
  name: keyVaultName
}

// Existing Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: logAnalyticsWorkspaceName
}

// Existing Resource - Storage Account - NSG Flow Logs
//////////////////////////////////////////////////
resource nsgFlowLogsStorageAccount 'Microsoft.Storage/storageAccounts@2021-01-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: nsgFlowLogsStorageAccountName
}

// Resource Group - Networking
//////////////////////////////////////////////////
resource networkingResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: networkingResourceGroupName
  location: azureRegion
}

// Module - Nat Gateway
//////////////////////////////////////////////////
module natGatewayModule './azure_nat_gateway.bicep' = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'natGatewayDeployment'
  dependsOn: [
    networkingResourceGroup
  ]
  params: {
    natGatewayName: natGatewayName
    natGatewayPublicIPPrefixName: natGatewayPublicIPPrefixName
  }
}

// Module - Network Security Group
//////////////////////////////////////////////////
module networkSecurityGroupsModule './azure_network_security_group.bicep' = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'networkSecurityGroupsDeployment'
  dependsOn: [
    networkingResourceGroup
  ]
  params: {
    adeAppVmssSubnetNSGName: adeAppVmssSubnetNSGName
    adeAppVmSubnetNSGName: adeAppVmSubnetNSGName
    adeWebVmssSubnetNSGName: adeWebVmssSubnetNSGName
    adeWebVmSubnetNSGName: adeWebVmSubnetNSGName
    azureBastionSubnetNSGName: azureBastionSubnetNSGName
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    managementSubnetNSGName: managementSubnetNSGName
    sourceAddressPrefix: sourceAddressPrefix
  }
}

// Module - Route Table
//////////////////////////////////////////////////
module routeTableModule './azure_route_table.bicep' = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'routeTableDeployment'
  dependsOn: [
    networkingResourceGroup
  ]
  params: {
    internetRouteTableName: internetRouteTableName
  }
}

// Module - Virtual Network - Virtual Network 001
//////////////////////////////////////////////////
module virtualNetwork001Module './azure_virtual_network_001.bicep' = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'virtualNetwork001Deployment'
  dependsOn: [
    networkingResourceGroup
  ]
  params: {
    applicationGatewaySubnetName: applicationGatewaySubnetName
    applicationGatewaySubnetPrefix: applicationGatewaySubnetPrefix
    azureBastionSubnetName: azureBastionSubnetName
    azureBastionSubnetNSGId: networkSecurityGroupsModule.outputs.azureBastionSubnetNSGId
    azureBastionSubnetPrefix: azureBastionSubnetPrefix
    azureFirewallSubnetName: azureFirewallSubnetName
    azureFirewallSubnetPrefix: azureFirewallSubnetPrefix
    gatewaySubnetName: gatewaySubnetName
    gatewaySubnetPrefix: gatewaySubnetPrefix
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    managementSubnetName: managementSubnetName
    managementSubnetNSGId: networkSecurityGroupsModule.outputs.managementSubnetNSGId
    managementSubnetPrefix: managementSubnetPrefix
    virtualNetwork001Name: virtualNetwork001Name
    virtualnetwork001Prefix: virtualnetwork001Prefix
  }
}

// Module - Virtual Network - Virtual Network 002
//////////////////////////////////////////////////
module virtualNetwork002Module './azure_virtual_network_002.bicep' = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'virtualNetwork002Deployment'
  dependsOn: [
    networkingResourceGroup
  ]
  params: {
    adeAppAksSubnetName: adeAppAksSubnetName
    adeAppAksSubnetPrefix: adeAppAksSubnetPrefix
    adeAppVmssSubnetName: adeAppVmssSubnetName
    adeAppVmssSubnetNSGId: networkSecurityGroupsModule.outputs.adeAppVmssSubnetNSGId
    adeAppVmssSubnetPrefix: adeAppVmssSubnetPrefix
    adeAppVmSubnetName: adeAppVmSubnetName
    adeAppVmSubnetNSGId: networkSecurityGroupsModule.outputs.adeAppVmSubnetNSGId
    adeAppVmSubnetPrefix: adeAppVmSubnetPrefix
    adeWebVmssSubnetName: adeWebVmssSubnetName
    adeWebVmssSubnetNSGId: networkSecurityGroupsModule.outputs.adeWebVmssSubnetNSGId
    adeWebVmssSubnetPrefix: adeWebVmssSubnetPrefix
    adeWebVmSubnetName: adeWebVmSubnetName
    adeWebVmSubnetNSGId: networkSecurityGroupsModule.outputs.adeWebVmSubnetNSGId
    adeWebVmSubnetPrefix: adeWebVmSubnetPrefix
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    natGatewayId: natGatewayModule.outputs.natGatewayId
    privateEndpointSubnetName: privateEndpointSubnetName
    privateEndpointSubnetPrefix: privateEndpointSubnetPrefix
    virtualNetwork002Name: virtualNetwork002Name
    virtualnetwork002Prefix: virtualnetwork002Prefix
    vnetIntegrationSubnetName: vnetIntegrationSubnetName
    vnetIntegrationSubnetPrefix: vnetIntegrationSubnetPrefix
  }
}

// Module - Azure Firewall
//////////////////////////////////////////////////
module azureFirewallModule './azure_firewall.bicep' = if (deployAzureFirewall == true) {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'azureFirewallDeployment'
  dependsOn: [
    networkingResourceGroup
  ]
  params: {
    azureFirewallName: azureFirewallName
    azureFirewallPublicIpAddressName: azureFirewallPublicIpAddressName
    azureFirewallSubnetId: virtualNetwork001Module.outputs.azureFirewallSubnetId
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
  }
}

// Module - Azure Bastion
//////////////////////////////////////////////////
module azureBastionModule './azure_bastion.bicep' = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'azureBastionDeployment'
  dependsOn: [
    networkingResourceGroup
  ]
  params: {
    azureBastionName: azureBastionName
    azureBastionPublicIpAddressName: azureBastionPublicIpAddressName
    azureBastionSubnetId: virtualNetwork001Module.outputs.azureBastionSubnetId
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
  }
}

// Module - Azure Vpn Gateway
//////////////////////////////////////////////////
module azureVpnGatewayModule './azure_vpn_gateway.bicep' = if (deployVpnGateway == true) {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'vpnGatewayDeployment'
  dependsOn: [
    networkingResourceGroup
  ]
  params: {
    connectionName: connectionName
    connectionSharedKey: keyVault.getSecret('resourcePassword')
    gatewaySubnetId: virtualNetwork001Module.outputs.gatewaySubnetId
    localNetworkGatewayAddressPrefix: localNetworkGatewayAddressPrefix
    localNetworkGatewayName: localNetworkGatewayName
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    sourceAddressPrefix: sourceAddressPrefix
    vpnGatewayName: vpnGatewayName
    vpnGatewayPublicIpAddressName: vpnGatewayPublicIpAddressName
  }
}

// Module - Virtual Network Peering (deployVpnGateway == true)
//////////////////////////////////////////////////
module vnetPeeringVgwModule './azure_vnet_peering_vgw.bicep' = if (deployVpnGateway == true) {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'vnetPeeringVgwDeployment'
  dependsOn: [
    networkingResourceGroup
  ]
  params: {
    virtualNetwork001Id: virtualNetwork001Module.outputs.virtualNetwork001Id
    virtualNetwork001Name: virtualNetwork001Name
    virtualNetwork002Id: virtualNetwork002Module.outputs.virtualNetwork002Id
    virtualNetwork002Name: virtualNetwork002Name
  }
}

// Module - Virtual Network Peering (deployVpnGateway == false)
//////////////////////////////////////////////////
module vnetPeeringNoVgwModule './azure_vnet_peering_no_vgw.bicep' = if (deployVpnGateway == false) {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'vnetPeeringNoVgwDeployment'
  dependsOn: [
    networkingResourceGroup
  ]
  params: {
    virtualNetwork001Id: virtualNetwork001Module.outputs.virtualNetwork001Id
    virtualNetwork001Name: virtualNetwork001Name
    virtualNetwork002Id: virtualNetwork002Module.outputs.virtualNetwork002Id
    virtualNetwork002Name: virtualNetwork002Name
  }
}

// Module - Private Dns
//////////////////////////////////////////////////
module privateDnsModule './azure_private_dns.bicep' = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'privateDnsDeployment'
  dependsOn: [
    networkingResourceGroup
  ]
  params: {
    appServicePrivateDnsZoneName: appServicePrivateDnsZoneName
    azureSQLPrivateDnsZoneName: azureSQLprivateDnsZoneName
    virtualNetwork001Id: virtualNetwork001Module.outputs.virtualNetwork001Id
    virtualNetwork001Name: virtualNetwork001Name
    virtualNetwork002Id: virtualNetwork002Module.outputs.virtualNetwork002Id
    virtualNetwork002Name: virtualNetwork002Name
  }
}

// Module - Network Security Group Flow Logs
//////////////////////////////////////////////////
module nsgFlowLogsModule './azure_network_security_group_flow_logs.bicep' = {
  scope: resourceGroup(networkWatcherResourceGroupName)
  name: 'nsgFlowLogsDeployment'
  dependsOn: [
    networkingResourceGroup
  ]
  params: {
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    nsgConfigurations: networkSecurityGroupsModule.outputs.nsgConfigurations
    nsgFlowLogsStorageAccountId: nsgFlowLogsStorageAccount.id
  }
}
