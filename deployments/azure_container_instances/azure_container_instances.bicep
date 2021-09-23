// target scope
targetScope = 'subscription'

// parameters
param defaultPrimaryRegion string
param aliasRegion string
param rootDomainName string
param monitorResourceGroupName string
param keyVaultResourceGroupName string
param containerRegistryResourceGroupName string
param adeAppLoadTestingResourceGroupName string

// existing resources
// variables
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
// resource - log analytics workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: logAnalyticsWorkspaceName
}
// existing resources
// variables
var keyVaultName = 'kv-ade-${aliasRegion}-001'
// resource key vault
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  scope: resourceGroup(keyVaultResourceGroupName)
  name: keyVaultName
}
// existing resources
// variables
var azureContainerRegistryName = replace('acr-ade-${aliasRegion}-001', '-', '')
// resource - azure container registry
resource azureContainerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' existing = {
  scope: resourceGroup(containerRegistryResourceGroupName)
  name: azureContainerRegistryName
}

// module - azure container instances - ade load testing - redis
// variables
var adeLoadTestingRedisContainerGroupName = 'ci-ade-${aliasRegion}-adeloadtesting-redis'
var adeLoadTestingRedisContainerImageName = '${azureContainerRegistry.properties.loginServer}/ade-loadtesting-redis:latest'

// module deployment
module azureContainerInstancesADELoadTestingRedisModule 'azure_container_instances_adeloadtesting_redis.bicep' = {
  scope: resourceGroup(adeAppLoadTestingResourceGroupName)
  name: 'azureContainerInstancesADELoadTestingRedisDeployment'
  params: {
    defaultPrimaryRegion: defaultPrimaryRegion
    containerRegistryLoginServer: azureContainerRegistry.properties.loginServer
    containerRegistryLoginUserName: keyVault.getSecret('containerRegistryUserName')
    containerRegistryLoginPassword: keyVault.getSecret('containerRegistryPassword')
    adeLoadTestingRedisContainerGroupName: adeLoadTestingRedisContainerGroupName
    adeLoadTestingRedisContainerImageName: adeLoadTestingRedisContainerImageName
  }
}

// module - azure container instances - ade load testing - influxdb
// variables
var adeLoadTestingInfluxDBContainerGroupName = 'ci-ade-${aliasRegion}-adeloadtesting-influxdb'
var adeLoadTestingInfluxDBContainerImageName = '${azureContainerRegistry.properties.loginServer}/ade-loadtesting-influxdb:latest'

// module deployment
module azureContainerInstancesADELoadTestingInfluxDBModule 'azure_container_instances_adeloadtesting_influxdb.bicep' = {
  scope: resourceGroup(adeAppLoadTestingResourceGroupName)
  name: 'azureContainerInstancesADELoadTestingInfluxDBDeployment'
  params: {
    defaultPrimaryRegion: defaultPrimaryRegion
    containerRegistryLoginServer: azureContainerRegistry.properties.loginServer
    containerRegistryLoginUserName: keyVault.getSecret('containerRegistryUserName')
    containerRegistryLoginPassword: keyVault.getSecret('containerRegistryPassword')
    adeLoadTestingInfluxDBContainerGroupName: adeLoadTestingInfluxDBContainerGroupName
    adeLoadTestingInfluxDBContainerImageName: adeLoadTestingInfluxDBContainerImageName
  }
}

// module - azure container instances - ade load testing - grafana
// variables
var adeLoadTestingGrafanaContainerGroupName = 'ci-ade-${aliasRegion}-adeloadtesting-grafana'
var adeLoadTestingGrafanaContainerImageName = '${azureContainerRegistry.properties.loginServer}/ade-loadtesting-grafana:latest'

// module deployment
module azureContainerInstancesADELoadTestingGrafanaModule 'azure_container_instances_adeloadtesting_grafana.bicep' = {
  scope: resourceGroup(adeAppLoadTestingResourceGroupName)
  name: 'azureContainerInstancesADELoadTestingGrafanaDeployment'
  params: {
    defaultPrimaryRegion: defaultPrimaryRegion
    containerRegistryLoginServer: azureContainerRegistry.properties.loginServer
    containerRegistryLoginUserName: keyVault.getSecret('containerRegistryUserName')
    containerRegistryLoginPassword: keyVault.getSecret('containerRegistryPassword')
    adeLoadTestingGrafanaContainerGroupName: adeLoadTestingGrafanaContainerGroupName
    adeLoadTestingGrafanaContainerImageName: adeLoadTestingGrafanaContainerImageName
    adeLoadTestingInfluxDBDNSNameLabal: azureContainerInstancesADELoadTestingInfluxDBModule.outputs.influxFqdn
  }
}

// module - azure container instances - ade load testing - gatling
// variables
var adeLoadTestingGatlingContainerGroupName = 'ci-ade-${aliasRegion}-adeloadtesting-gatling'
var adeLoadTestingGatlingContainerImageName = '${azureContainerRegistry.properties.loginServer}/ade-loadtesting-gatling:latest'
var adeAppFrontEndHostName = 'ade-frontend.${rootDomainName}'
var adeAppApiGatewayHostName = 'ade-apigateway.${rootDomainName}'

// module deployment
module azureContainerInstancesADELoadTestingGatlingModule 'azure_container_instances_adeloadtesting_gatling.bicep' = {
  scope: resourceGroup(adeAppLoadTestingResourceGroupName)
  name: 'azureContainerInstancesADELoadTestingGatlingDeployment'
  params: {
    defaultPrimaryRegion: defaultPrimaryRegion
    containerRegistryLoginServer: azureContainerRegistry.properties.loginServer
    containerRegistryLoginUserName: keyVault.getSecret('containerRegistryUserName')
    containerRegistryLoginPassword: keyVault.getSecret('containerRegistryPassword')
    adeLoadTestingGatlingContainerGroupName: adeLoadTestingGatlingContainerGroupName
    adeLoadTestingGatlingContainerImageName: adeLoadTestingGatlingContainerImageName
    adeLoadTestingRedisDNSNameLabal: azureContainerInstancesADELoadTestingRedisModule.outputs.redisFqdn
    adeLoadTestingInfluxDBDNSNameLabal: azureContainerInstancesADELoadTestingInfluxDBModule.outputs.influxFqdn
    adeAppFrontEndHostName: adeAppFrontEndHostName
    adeAppApiGatewayHostName: adeAppApiGatewayHostName
  }
}
