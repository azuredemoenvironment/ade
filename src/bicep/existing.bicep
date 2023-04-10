// Parameters
//////////////////////////////////////////////////
@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('The name of the Container Resource Group.')
param containerResourceGroupName string

@description('The name of the Database Resource Group.')
param databaseResourceGroupName string

@description('The name of the Management Resource Group.')
param managementResourceGroupName string

@description('The name of the Networking Resource Group.')
param networkingResourceGroupName string

@description('The value for Root Domain Name.')
param rootDomainName string

@description('The name of the Security Resource Group.')
param securityResourceGroupName string

// Variables - Existing Resources
//////////////////////////////////////////////////
var adeAppAksSubnetName = 'snet-${appEnvironment}-adeApp-aks'
var adeAppSqlSubnetName = 'snet-${appEnvironment}-adeAppSql'
var adeAppVmssSubnetName = 'snet-${appEnvironment}-adeApp-vmss'
var adeAppVmSubnetName = 'snet-${appEnvironment}-adeApp-vm'
var adeWebVmssSubnetName = 'snet-${appEnvironment}-adeWeb-vmss'
var adeWebVmSubnetName = 'snet-${appEnvironment}-adeWeb-vm'
var appConfigName = 'appcs-${appEnvironment}'
var applicationGatewayManagedIdentityName = 'id-${appEnvironment}-applicationGateway'
var applicationGatewaySubnetName = 'snet-${appEnvironment}-applicationGateway'
var applicationInsightsName = 'appinsights-${appEnvironment}'
var appServicePrivateDnsZoneName = 'privatelink.azurewebsites.net'
var azureSqlPrivateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'
var bastionSubnetName = 'AzureBastionSubnet'
var containerRegistryManagedIdentityName = 'id-${appEnvironment}-containerRegistry'
var containerRegistryName = replace('acr-${appEnvironment}', '-', '')
var dataCollectionRuleName = 'dcr-${appEnvironment}-vmInsights'
var dataIngestorServiceSubnetName = 'snet-${appEnvironment}-dataIngestorService'
var dataReporterServiceSubnetName = 'snet-${appEnvironment}-dataReporterService'
var eventHubNamespaceAuthorizationRuleName = 'RootManageSharedAccessKey'
var eventHubNamespaceName = 'evhns-${appEnvironment}-diagnostics'
var eventIngestorServiceSubnetName = 'snet-${appEnvironment}-eventIngestorService'
var firewallSubnetName = 'AzureFirewallSubnet'
var gatewaySubnetName = 'GatewaySubnet'
var hubVirtualNetworkName = 'vnet-${appEnvironment}-hub'
var inspectorGadgetSqlDatabaseName = 'sqldb-${appEnvironment}-inspectorgadget'
var inspectorGadgetSqlServerName = 'sql-${appEnvironment}-inspectorgadget'
var inspectorGadgetSqlSubnetName = 'snet-${appEnvironment}-inspectorGadgetSql'
var keyVaultName = 'kv-${appEnvironment}'
var keyVaultSecretName = 'certificate'
var logAnalyticsWorkspaceName = 'log-${appEnvironment}'
var publicDnsZoneName = rootDomainName
var spokeVirtualNetworkName = 'vnet-${appEnvironment}-spoke'
var storageAccountName = replace('sa-diag-${uniqueString(subscription().subscriptionId)}', '-', '')
var userServiceSubnetName = 'snet-${appEnvironment}-userService'
var virtualMachineManagedIdentityName = 'id-${appEnvironment}-virtualMachine'
var vnetIntegrationSubnetName = 'snet-${appEnvironment}-vnetIntegration'

// Existing Resource - App Config
//////////////////////////////////////////////////
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' existing = {
  scope: resourceGroup(securityResourceGroupName)
  name: appConfigName
}

// Existing Resource - Application Insights
//////////////////////////////////////////////////
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: applicationInsightsName
}

// Existing Resource - Container Registry
//////////////////////////////////////////////////
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' existing = {
  scope: resourceGroup(containerResourceGroupName)
  name: containerRegistryName
}

// Existing Resource - Data Collection Rule - VM Insights
//////////////////////////////////////////////////
resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: dataCollectionRuleName
}

// Existing Resource - Event Hub Authorization Rule
//////////////////////////////////////////////////
resource eventHubNamespaceAuthorizationRule 'Microsoft.EventHub/namespaces/authorizationRules@2022-10-01-preview' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: '${eventHubNamespaceName}/${eventHubNamespaceAuthorizationRuleName}'
}

// Existing Resource - Key Vault
//////////////////////////////////////////////////
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  scope: resourceGroup(securityResourceGroupName)
  name: keyVaultName
  resource keyVaultSecret 'secrets' existing = {
    name: keyVaultSecretName
  }
}
// Existing Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: logAnalyticsWorkspaceName
}

// Existing Resource - Managed Identity - Application Gateway
//////////////////////////////////////////////////
resource applicationGatewayManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup(securityResourceGroupName)
  name: applicationGatewayManagedIdentityName
}

// Existing Resource - Managed Identity - Container Registry
//////////////////////////////////////////////////
resource containerRegistryManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup(securityResourceGroupName)
  name: containerRegistryManagedIdentityName
}

// Existing Resource - Managed Identity - Virtual Machine
//////////////////////////////////////////////////
resource virtualMachineManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup(securityResourceGroupName)
  name: virtualMachineManagedIdentityName
}

// Existing Resource - Private Dns Zone - App Service
resource appServicePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: appServicePrivateDnsZoneName
}

// Existing Resource - Private Dns Zone - Azure Sql
resource azureSqlPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: azureSqlPrivateDnsZoneName
}

// Existing Resource - Public Dns Zone
resource publicDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: publicDnsZoneName
}

// Existing Resource - Sql Database - Inspector Gadget
//////////////////////////////////////////////////
resource inspectorGadgetSqlDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' existing = {
  scope: resourceGroup(databaseResourceGroupName)
  name: inspectorGadgetSqlDatabaseName
}

// Existing Resource - Sql Server - Inspectorgadget
//////////////////////////////////////////////////
resource inspectorGadgetSqlServer 'Microsoft.Sql/servers@2020-11-01-preview' existing = {
  scope: resourceGroup(databaseResourceGroupName)
  name: inspectorGadgetSqlServerName
}

// Existing Resource - Storage Account - Diagnostics
//////////////////////////////////////////////////
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: storageAccountName
}

// Existing Resource - Virtual Network - Hub
//////////////////////////////////////////////////
resource hubVirtualNetwork 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: hubVirtualNetworkName
  resource firewallSubnet 'subnets@2022-09-01' existing = {
    name: firewallSubnetName
  }
  resource applicationGatewaySubnet 'subnets@2022-09-01' existing = {
    name: applicationGatewaySubnetName
  }
  resource bastionSubnet 'subnets@2022-09-01' existing = {
    name: bastionSubnetName
  }
  resource gatewaySubnet 'subnets@2022-09-01' existing = {
    name: gatewaySubnetName
  }
}

// Existing Resource - Virtual Network - Spoke
//////////////////////////////////////////////////
resource spokeVirtualNetwork 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: spokeVirtualNetworkName
  resource adeWebVmSubnet 'subnets@2022-09-01' existing = {
    name: adeWebVmSubnetName
  }
  resource adeAppVmSubnet 'subnets@2022-09-01' existing = {
    name: adeAppVmSubnetName
  }
  resource adeWebVmssSubnet 'subnets@2022-09-01' existing = {
    name: adeWebVmssSubnetName
  }
  resource adeAppVmssSubnet 'subnets@2022-09-01' existing = {
    name: adeAppVmssSubnetName
  }
  resource adeAppAksSubnet 'subnets@2022-09-01' existing = {
    name: adeAppAksSubnetName
  }  
  resource userServiceSubnet 'subnets@2022-09-01' existing = {
    name: userServiceSubnetName
  }
  resource dataIngestorServiceSubnet 'subnets@2022-09-01' existing = {
    name: dataIngestorServiceSubnetName
  }
  resource dataReporterServiceSubnet 'subnets@2022-09-01' existing = {
    name: dataReporterServiceSubnetName
  }
  resource eventIngestorServiceSubnet 'subnets@2022-09-01' existing = {
    name: eventIngestorServiceSubnetName
  }
  resource adeAppSqlSubnet 'subnets@2022-09-01' existing = {
    name: adeAppSqlSubnetName
  }
  resource inspectorGadgetSqlSubnet 'subnets@2022-09-01' existing = {
    name: inspectorGadgetSqlSubnetName
  }
  resource vnetIntegrationSubnet 'subnets@2022-09-01' existing = {
    name: vnetIntegrationSubnetName
  }
}

// Outputs
//////////////////////////////////////////////////


output inspectorGadgetSqlDatabaseId string = inspectorGadgetSqlDatabase.id

output inspectorGadgetSqlServerId string = inspectorGadgetSqlServer.id

output storageAccountId string = storageAccount.id

output hubVirtualNetworkId string = hubVirtualNetwork.id
output firewallSubnetId string = hubVirtualNetwork::firewallSubnet.id
output applicationGatewaySubnetId string = hubVirtualNetwork::applicationGatewaySubnet.id
output bastionSubnetId string = hubVirtualNetwork::bastionSubnet.id
output gatewaySubnetId string = hubVirtualNetwork::gatewaySubnet.id

output spokeVirtualNetworkId string = spokeVirtualNetwork.id
output adeWebVmSubnetId string = spokeVirtualNetwork::adeWebVmSubnet.id
output adeAppVmSubnetId string = spokeVirtualNetwork::adeAppVmSubnet.id
output adeWebVmssSubnetNameId string = spokeVirtualNetwork::adeWebVmssSubnet.id
output adeAppVmssSubnetNameId string = spokeVirtualNetwork::adeAppVmssSubnet.id
output adeAppAksSubnetId string = spokeVirtualNetwork::adeAppAksSubnet.id
output userServiceSubnetId string = spokeVirtualNetwork::userServiceSubnet.id
output dataIngestorServiceSubnetId string = spokeVirtualNetwork::dataIngestorServiceSubnet.id
output eventIngestorServiceSubnetId string = spokeVirtualNetwork::eventIngestorServiceSubnet.id
output adeAppSqlSubnetId string = spokeVirtualNetwork::adeAppSqlSubnet.id
output inspectorGadgetSqlSubnetId string = spokeVirtualNetwork::inspectorGadgetSqlSubnet.id
output vnetIntegrationSubnetId string = spokeVirtualNetwork::vnetIntegrationSubnet.id
