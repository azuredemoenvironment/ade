// target scope
targetScope = 'subscription'

// parameters
param defaultPrimaryRegion string
param aliasRegion string
param appServicePlanResourceGroupName string
param adeAppAppServicesResourceGroupName string
param inspectorGadgetResourceGroupName string
param adminUserName string
param adminPassword string

// existing resources
// variables - log analytics
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'

// variables - application insights
var applicationInsightsName = 'appinsights-ade-${aliasRegion}-001'

// variables - virtual network - virtual network 002
var networkingResourceGroupName = 'rg-ade-${aliasRegion}-networking'
var virtualNetwork002Name = 'vnet-ade-${aliasRegion}-002'
var vnetIntegrationSubnetName = 'snet-vnetIntegration'

// variables - private dns zone - azure app services
var azureAppServicePrivateDnsZoneName = 'privatelink.azurewebsites.net'

// variables - inspectorGadgetSql
var inspectorGadgetSqlServerName = 'sql-ade-${aliasRegion}-inspectorgadget'
var inspectorGadgetSqlDatabaseName = 'sqldb-ade-${aliasRegion}-inspectorgadget'

// template resources
// variables - app service plan
var appServicePlanName = 'plan-ade-${aliasRegion}-001'

// variables - inspectorGadgetAppService
var inspectorGadgetAppServiceName = replace('app-${aliasRegion}-inspectorgadget', '-', '')

// module - resource groups
module resourceGroupsModule './azure_app_services_resourcegroups.bicep' = {
  name: 'resourceGroupsDeployment'
  params: {
    defaultPrimaryRegion: defaultPrimaryRegion
    appServicePlanResourceGroupName: appServicePlanResourceGroupName
    adeAppAppServicesResourceGroupName: adeAppAppServicesResourceGroupName
    inspectorGadgetResourceGroupName: inspectorGadgetResourceGroupName
  }
}

// module - app service plan
module appServicePlanModule 'azure_app_service_plan.bicep' = {
  scope: resourceGroup(appServicePlanResourceGroupName)
  name: 'appServicePlanDeployment'
  params: {
    defaultPrimaryRegion: defaultPrimaryRegion
    appServicePlanName: appServicePlanName
  }
}

// module - inspectorGadgetAppService
module inspectorGadgetAppService 'azure_app_services_inspectorgadget.bicep' = {
  scope: resourceGroup(inspectorGadgetResourceGroupName)
  name: 'inspectorGadgetAppServiceDeployment'
  params: {
    defaultPrimaryRegion: defaultPrimaryRegion
    adminUserName: adminUserName
    adminPassword: adminPassword
    monitorResourceGroupName: monitorResourceGroupName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    applicationInsightsName: applicationInsightsName
    networkingResourceGroupName: networkingResourceGroupName
    virtualNetwork002Name: virtualNetwork002Name
    vnetIntegrationSubnetName: vnetIntegrationSubnetName
    inspectorGadgetResourceGroupName: inspectorGadgetResourceGroupName
    inspectorGadgetSqlServerName: inspectorGadgetSqlServerName
    inspectorGadgetSqlDatabaseName: inspectorGadgetSqlDatabaseName
    inspectorGadgetAppServiceName: inspectorGadgetAppServiceName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
  }
}
