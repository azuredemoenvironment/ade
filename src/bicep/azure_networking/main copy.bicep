// Parameters
//////////////////////////////////////////////////
@description('The application environment (workoad, environment, location).')
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
var adeAppAksSubnetName = 'snet-${appEnvironment}-adeApp-aks'
var adeAppAksSubnetPrefix = '10.102.101.0/24'
var adeAppSqlSubnetName = 'snet-${appEnvironment}-adeAppSql'
var adeAppSqlSubnetNsgName = 'nsg-${appEnvironment}-adeAppSql'
var adeAppSqlSubnetPrefix = '10.102.160.0/24'
var adeAppVmssSubnetName = 'snet-${appEnvironment}-adeApp-vmss'
var adeAppVmssSubnetNsgName = 'nsg-${appEnvironment}-adeApp-vmss'
var adeAppVmssSubnetPrefix = '10.102.12.0/24'
var adeAppVmSubnetName = 'snet-${appEnvironment}-adeApp-vm'
var adeAppVmSubnetNsgName = 'nsg-${appEnvironment}-adeApp-vm'
var adeAppVmSubnetPrefix = '10.102.2.0/24'
var adeWebVmssSubnetName = 'snet-${appEnvironment}-adeWeb-vmss'
var adeWebVmssSubnetNsgName = 'nsg-${appEnvironment}-adeWeb-vmss'
var adeWebVmssSubnetPrefix = '10.102.11.0/24'
var adeWebVmSubnetName = 'snet-${appEnvironment}-adeWeb-vm'
var adeWebVmSubnetNsgName = 'nsg-${appEnvironment}-adeWeb-vm'
var adeWebVmSubnetPrefix = '10.102.1.0/24'
var applicationGatewaySubnetName = 'snet-${appEnvironment}-applicationGateway'
var applicationGatewaySubnetNsgName = 'nsg-${appEnvironment}-applicationGateway'
var applicationGatewaySubnetPrefix = '10.101.11.0/24'
var appServicePrivateDnsZoneName = 'privatelink.azurewebsites.net'
var azureBastionName = 'bastion-${appEnvironment}-001'
var azureBastionPublicIpAddressName = 'pip-${appEnvironment}-bastion001'
var azureBastionSubnetName = 'AzureBastionSubnet'
var azureBastionSubnetNsgName = 'nsg-${appEnvironment}-bastion'
var azureBastionSubnetPrefix = '10.101.21.0/24'
var azureFirewallName = 'fw-${appEnvironment}-001'
var azureFirewallPublicIpAddressName = 'pip-${appEnvironment}-fw001'
var azureFirewallSubnetName = 'AzureFirewallSubnet'
var azureFirewallSubnetPrefix = '10.101.1.0/24'
var azureSQLprivateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'
var connectionName = 'cn-${appEnvironment}-vgw001'
var dataIngestorServiceSubnetName = 'snet-${appEnvironment}-dataIngestorService'
var dataIngestorServiceSubnetNsgName = 'nsg-${appEnvironment}-dataIngestorService'
var dataIngestorServiceSubnetPrefix = '10.102.152.0/24'
var dataReporterServiceSubnetName = 'snet-${appEnvironment}-dataReporterService'
var dataReporterServiceSubnetNsgName = 'nsg-${appEnvironment}-dataReporterService'
var dataReporterServiceSubnetPrefix = '10.102.153.0/24'
var eventIngestorServiceSubnetName = 'snet-${appEnvironment}-eventIngestorService'
var eventIngestorServiceSubnetNsgName = 'nsg-${appEnvironment}-eventIngestorService'
var eventIngestorServiceSubnetPrefix = '10.102.154.0/24'
var gatewaySubnetName = 'GatewaySubnet'
var gatewaySubnetPrefix = '10.101.255.0/24'
var inspectorGadgetSqlSubnetName = 'snet-${appEnvironment}-inspectorGadgetSql'
var inspectorGadgetSqlSubnetNsgName = 'nsg-${appEnvironment}-inspectorGadgetSql'
var inspectorGadgetSqlSubnetPrefix = '10.102.161.0/24'
var internetRouteTableName = 'route-${appEnvironment}-internet'
var keyVaultName = 'kv-${appEnvironment}-001'
var localNetworkGatewayName = 'lgw-${appEnvironment}-vgw001'
var logAnalyticsWorkspaceName = 'log-${appEnvironment}-001'
var managementSubnetName = 'snet-${appEnvironment}-management'
var managementSubnetNsgName = 'nsg-${appEnvironment}-management'
var managementSubnetPrefix = '10.101.31.0/24'
var natGatewayName = 'ngw-${appEnvironment}-001'
var natGatewayPublicIPPrefixName = 'pipp-${appEnvironment}-ngw001'
var networkWatcherResourceGroupName = 'NetworkWatcherRG'
var nsgFlowLogsStorageAccountName = replace('sa-${appEnvironment}-nsgflow', '-', '')
var tags = {
  deploymentDate: deploymentDate
  owner: ownerName
}
var userServiceSubnetName = 'snet-${appEnvironment}-userService'
var userServiceSubnetNsgName = 'nsg-${appEnvironment}-userService'
var userServiceSubnetPrefix = '10.102.151.0/24'
var virtualNetwork001Name = 'vnet-${appEnvironment}-001'
var virtualnetwork001Prefix = '10.101.0.0/16'
var virtualNetwork002Name = 'vnet-${appEnvironment}-002'
var virtualnetwork002Prefix = '10.102.0.0/16'
var vnetIntegrationSubnetName = 'snet-${appEnvironment}-vnetIntegration'
var vnetIntegrationSubnetNsgName = 'nsg-${appEnvironment}-vnetIntegration'
var vnetIntegrationSubnetPrefix = '10.102.201.0/24'
var vpnGatewayName = 'vpng-${appEnvironment}-001'
var vpnGatewayPublicIpAddressName = 'pip-${appEnvironment}-vgw001'

// Existing Resource - Event Hub Authorization Rule
//////////////////////////////////////////////////
var eventHubNamespaceAuthorizationRuleName = 'evh-${appEnvironment}-diagnostics/RootManageSharedAccessKey'
resource eventHubNamespaceAuthorizationRule 'Microsoft.EventHub/namespaces/authorizationRules@2021-11-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: eventHubNamespaceAuthorizationRuleName
}

// Existing Resource - Key Vault
//////////////////////////////////////////////////
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  scope: resourceGroup(securityResourceGroupName)
  name: keyVaultName
}

// Existing Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: logAnalyticsWorkspaceName
}

// Existing Resource - Storage Account - Diagnostics
//////////////////////////////////////////////////
var diagnosticsStorageAccountName = replace('sa-${appEnvironment}-diags', '-', '')
resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: diagnosticsStorageAccountName
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
  }
}

// Module - Network Security Group
//////////////////////////////////////////////////
module networkSecurityGroupsModule './network_security_group.bicep' = {
  name: 'networkSecurityGroupsDeployment'
  params: {
    adeAppSqlSubnetNsgName: adeAppSqlSubnetNsgName
    adeAppVmssSubnetNsgName: adeAppVmssSubnetNsgName
    adeAppVmSubnetNsgName: adeAppVmSubnetNsgName
    adeWebVmssSubnetNsgName: adeWebVmssSubnetNsgName
    adeWebVmSubnetNsgName: adeWebVmSubnetNsgName
    applicationGatewaySubnetNsgName: applicationGatewaySubnetNsgName
    azureBastionSubnetNsgName: azureBastionSubnetNsgName
    dataIngestorServiceSubnetNsgName: dataIngestorServiceSubnetNsgName
    dataReporterServiceSubnetNsgName: dataReporterServiceSubnetNsgName
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    eventIngestorServiceSubnetNsgName: eventIngestorServiceSubnetNsgName
    inspectorGadgetSqlSubnetNsgName: inspectorGadgetSqlSubnetNsgName
    location: location    
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    managementSubnetNsgName: managementSubnetNsgName
    sourceAddressPrefix: sourceAddressPrefix
    userServiceSubnetNsgName: userServiceSubnetNsgName
    vnetIntegrationSubnetNsgName: vnetIntegrationSubnetNsgName
  }
}

// Module - Route Table
//////////////////////////////////////////////////
module routeTableModule './route_table.bicep' = {
  name: 'routeTableDeployment'
  params: {
    internetRouteTableName: internetRouteTableName
    location: location
  }
}

// Module - Virtual Network - Virtual Network 001
//////////////////////////////////////////////////
module virtualNetwork001Module './virtual_network_001.bicep' = {
  name: 'virtualNetwork001Deployment'
  params: {
    applicationGatewaySubnetName: applicationGatewaySubnetName
    applicationGatewaySubnetNsgId: networkSecurityGroupsModule.outputs.applicationGatewaySubnetNsgId
    applicationGatewaySubnetPrefix: applicationGatewaySubnetPrefix
    azureBastionSubnetName: azureBastionSubnetName
    azureBastionSubnetNsgId: networkSecurityGroupsModule.outputs.azureBastionSubnetNsgId
    azureBastionSubnetPrefix: azureBastionSubnetPrefix
    azureFirewallSubnetName: azureFirewallSubnetName
    azureFirewallSubnetPrefix: azureFirewallSubnetPrefix
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    gatewaySubnetName: gatewaySubnetName
    gatewaySubnetPrefix: gatewaySubnetPrefix
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    managementSubnetName: managementSubnetName
    managementSubnetNsgId: networkSecurityGroupsModule.outputs.managementSubnetNsgId
    managementSubnetPrefix: managementSubnetPrefix
    virtualNetwork001Name: virtualNetwork001Name
    virtualnetwork001Prefix: virtualnetwork001Prefix
  }
}

// Module - Virtual Network - Virtual Network 002
//////////////////////////////////////////////////
module virtualNetwork002Module './virtual_network_002.bicep' = {
  name: 'virtualNetwork002Deployment'
  params: {
    adeAppAksSubnetName: adeAppAksSubnetName
    adeAppAksSubnetPrefix: adeAppAksSubnetPrefix
    adeAppSqlSubnetName: adeAppSqlSubnetName
    adeAppSqlSubnetNsgId: networkSecurityGroupsModule.outputs.adeAppSqlSubnetNsgId
    adeAppSqlSubnetPrefix: adeAppSqlSubnetPrefix
    adeAppVmssSubnetName: adeAppVmssSubnetName
    adeAppVmssSubnetNsgId: networkSecurityGroupsModule.outputs.adeAppVmssSubnetNsgId
    adeAppVmssSubnetPrefix: adeAppVmssSubnetPrefix
    adeAppVmSubnetName: adeAppVmSubnetName
    adeAppVmSubnetNsgId: networkSecurityGroupsModule.outputs.adeAppVmSubnetNsgId
    adeAppVmSubnetPrefix: adeAppVmSubnetPrefix
    adeWebVmssSubnetName: adeWebVmssSubnetName
    adeWebVmssSubnetNsgId: networkSecurityGroupsModule.outputs.adeWebVmssSubnetNsgId
    adeWebVmssSubnetPrefix: adeWebVmssSubnetPrefix
    adeWebVmSubnetName: adeWebVmSubnetName
    adeWebVmSubnetNsgId: networkSecurityGroupsModule.outputs.adeWebVmSubnetNsgId
    adeWebVmSubnetPrefix: adeWebVmSubnetPrefix
    dataIngestorServiceSubnetName: dataIngestorServiceSubnetName
    dataIngestorServiceSubnetNsgId: networkSecurityGroupsModule.outputs.dataIngestorServiceSubnetNsgId
    dataIngestorServiceSubnetPrefix: dataIngestorServiceSubnetPrefix
    dataReporterServiceSubnetName: dataReporterServiceSubnetName
    dataReporterServiceSubnetNsgId: networkSecurityGroupsModule.outputs.dataReporterServiceSubnetNsgId
    dataReporterServiceSubnetPrefix: dataReporterServiceSubnetPrefix
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    eventIngestorServiceSubnetName: eventIngestorServiceSubnetName
    eventIngestorServiceSubnetNsgId: networkSecurityGroupsModule.outputs.eventIngestorServiceSubnetNsgId
    eventIngestorServiceSubnetPrefix: eventIngestorServiceSubnetPrefix
    inspectorGadgetSqlSubnetName: inspectorGadgetSqlSubnetName
    inspectorGadgetSqlSubnetNsgId: networkSecurityGroupsModule.outputs.inspectorGadgetSqlSubnetNsgId
    inspectorGadgetSqlSubnetPrefix: inspectorGadgetSqlSubnetPrefix
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    natGatewayId: natGatewayModule.outputs.natGatewayId
    userServiceSubnetName: userServiceSubnetName
    userServiceSubnetNsgId: networkSecurityGroupsModule.outputs.userServiceSubnetNsgId
    userServiceSubnetPrefix: userServiceSubnetPrefix
    virtualNetwork002Name: virtualNetwork002Name
    virtualnetwork002Prefix: virtualnetwork002Prefix
    vnetIntegrationSubnetName: vnetIntegrationSubnetName
    vnetIntegrationSubnetNsgId: networkSecurityGroupsModule.outputs.vnetIntegrationSubnetNsgId
    vnetIntegrationSubnetPrefix: vnetIntegrationSubnetPrefix
  }
}

// Module - Azure Firewall
//////////////////////////////////////////////////
module azureFirewallModule './firewall.bicep' = if (deployAzureFirewall == true) {
  name: 'azureFirewallDeployment'
  params: {
    azureFirewallName: azureFirewallName
    azureFirewallPublicIpAddressName: azureFirewallPublicIpAddressName
    azureFirewallSubnetId: virtualNetwork001Module.outputs.azureFirewallSubnetId
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
  }
}

// Module - Azure Bastion
//////////////////////////////////////////////////
module azureBastionModule './bastion.bicep' = {
  name: 'azureBastionDeployment'
  params: {
    azureBastionName: azureBastionName
    azureBastionPublicIpAddressName: azureBastionPublicIpAddressName
    azureBastionSubnetId: virtualNetwork001Module.outputs.azureBastionSubnetId
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location: location    
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
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
    gatewaySubnetId: virtualNetwork001Module.outputs.gatewaySubnetId
    localNetworkGatewayAddressPrefix: localNetworkGatewayAddressPrefix
    localNetworkGatewayName: localNetworkGatewayName
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    sourceAddressPrefix: sourceAddressPrefix
    vpnGatewayName: vpnGatewayName
    vpnGatewayPublicIpAddressName: vpnGatewayPublicIpAddressName
  }
}

// Module - Virtual Network Peering (deployVpnGateway == true)
//////////////////////////////////////////////////
module vnetPeeringVgwModule './vnet_peering_vgw.bicep' = if (deployVpnGateway == true) {
  name: 'vnetPeeringVgwDeployment'
  params: {
    virtualNetwork001Id: virtualNetwork001Module.outputs.virtualNetwork001Id
    virtualNetwork001Name: virtualNetwork001Name
    virtualNetwork002Id: virtualNetwork002Module.outputs.virtualNetwork002Id
    virtualNetwork002Name: virtualNetwork002Name
  }
}

// Module - Virtual Network Peering (deployVpnGateway == false)
//////////////////////////////////////////////////
module vnetPeeringNoVgwModule './vnet_peering_no_vgw.bicep' = if (deployVpnGateway == false) {
  name: 'vnetPeeringNoVgwDeployment'
  params: {
    virtualNetwork001Id: virtualNetwork001Module.outputs.virtualNetwork001Id
    virtualNetwork001Name: virtualNetwork001Name
    virtualNetwork002Id: virtualNetwork002Module.outputs.virtualNetwork002Id
    virtualNetwork002Name: virtualNetwork002Name
  }
}

// Module - Private Dns
//////////////////////////////////////////////////
module privateDnsModule './private_dns.bicep' = {
  name: 'privateDnsDeployment'
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
module nsgFlowLogsModule './network_security_group_flow_logs.bicep' = {
  scope: resourceGroup(networkWatcherResourceGroupName)
  name: 'nsgFlowLogsDeployment'
  params: {
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    nsgConfigurations: networkSecurityGroupsModule.outputs.nsgConfigurations
    nsgFlowLogsStorageAccountId: storageAccountNsgFlowLogsModule.outputs.storageAccountId
  }
}
