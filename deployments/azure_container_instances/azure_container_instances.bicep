// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'

// Parameters
//////////////////////////////////////////////////
@description('The user alias and Azure region defined from user input.')
param aliasRegion string

@description('The selected Azure region for deployment.')
param azureRegion string

@description('The location for all resources.')
param location string = deployment().location

@description('The value for Root Domain Name.')
param rootDomainName string

// Global Variables
//////////////////////////////////////////////////
// Resource Groups
var adeAppLoadTestingResourceGroupName = 'rg-ade-${aliasRegion}-adeapploadtesting'
var containerRegistryResourceGroupName = 'rg-ade-${aliasRegion}-containerregistry'
// Resources
var adeAppApiGatewayHostName = 'ade-apigateway.${rootDomainName}'
var adeAppFrontEndHostName = 'ade-frontend.${rootDomainName}'
var adeLoadTestingGatlingContainerGroupName = 'ci-ade-${aliasRegion}-adeloadtesting-gatling'
var adeLoadTestingGatlingContainerImageName = '${containerRegistry.properties.loginServer}/ade-loadtesting-gatling:latest'
var adeLoadTestingGrafanaContainerGroupName = 'ci-ade-${aliasRegion}-adeloadtesting-grafana'
var adeLoadTestingGrafanaContainerImageName = '${containerRegistry.properties.loginServer}/ade-loadtesting-grafana:latest'
var adeLoadTestingInfluxDbContainerGroupName = 'ci-ade-${aliasRegion}-adeloadtesting-influxdb'
var adeLoadTestingInfluxDbContainerImageName = '${containerRegistry.properties.loginServer}/ade-loadtesting-influxdb:latest'
var adeLoadTestingRedisContainerGroupName = 'ci-ade-${aliasRegion}-adeloadtesting-redis'
var adeLoadTestingRedisContainerImageName = '${containerRegistry.properties.loginServer}/ade-loadtesting-redis:latest'
var containerRegistryName = replace('acr-ade-${aliasRegion}-001', '-', '')

// Existing Resource - Container Registry
//////////////////////////////////////////////////
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' existing = {
  scope: resourceGroup(containerRegistryResourceGroupName)
  name: containerRegistryName
}

// Resource Group - App Service Plan
//////////////////////////////////////////////////
resource adeAppLoadTestingResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: adeAppLoadTestingResourceGroupName
  location: azureRegion
}

// Module - Azure Container Instances - Redis
//////////////////////////////////////////////////
module azureContainerInstancesADELoadTestingRedisModule 'azure_container_instances_adeloadtesting_redis.bicep' = {
  scope: resourceGroup(adeAppLoadTestingResourceGroupName)
  name: 'azureContainerInstancesADELoadTestingRedisDeployment'
  dependsOn: [
    adeAppLoadTestingResourceGroup
  ]
  params: {
    adeLoadTestingRedisContainerGroupName: adeLoadTestingRedisContainerGroupName
    adeLoadTestingRedisContainerImageName: adeLoadTestingRedisContainerImageName
    containerRegistryName: containerRegistryName
    containerRegistryPassword: first(listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords).value
    containerRegistryURL: containerRegistry.properties.loginServer
    location: location
  }
}

// Module - Azure Container Instances - InfluxDb
//////////////////////////////////////////////////
module azureContainerInstancesADELoadTestingInfluxDbModule 'azure_container_instances_adeloadtesting_influxdb.bicep' = {
  scope: resourceGroup(adeAppLoadTestingResourceGroupName)
  name: 'azureContainerInstancesADELoadTestingInfluxDbDeployment'
  dependsOn: [
    adeAppLoadTestingResourceGroup
  ]
  params: {
    adeLoadTestingInfluxDbContainerGroupName: adeLoadTestingInfluxDbContainerGroupName
    adeLoadTestingInfluxDbContainerImageName: adeLoadTestingInfluxDbContainerImageName
    containerRegistryName: containerRegistryName
    containerRegistryPassword: first(listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords).value
    containerRegistryURL: containerRegistry.properties.loginServer
    location: location
  }
}

// Module - Azure Container Instances - Grafana
//////////////////////////////////////////////////
module azureContainerInstancesADELoadTestingGrafanaModule 'azure_container_instances_adeloadtesting_grafana.bicep' = {
  scope: resourceGroup(adeAppLoadTestingResourceGroupName)
  name: 'azureContainerInstancesADELoadTestingGrafanaDeployment'
  dependsOn: [
    adeAppLoadTestingResourceGroup
  ]
  params: {
    adeLoadTestingGrafanaContainerGroupName: adeLoadTestingGrafanaContainerGroupName
    adeLoadTestingGrafanaContainerImageName: adeLoadTestingGrafanaContainerImageName
    adeLoadTestingInfluxDbDNSNameLabal: azureContainerInstancesADELoadTestingInfluxDbModule.outputs.influxFqdn
    containerRegistryName: containerRegistryName
    containerRegistryPassword: first(listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords).value
    containerRegistryURL: containerRegistry.properties.loginServer
    location: location
  }
}

// Module - Azure Container Instances - Gatling
//////////////////////////////////////////////////
module azureContainerInstancesADELoadTestingGatlingModule 'azure_container_instances_adeloadtesting_gatling.bicep' = {
  scope: resourceGroup(adeAppLoadTestingResourceGroupName)
  name: 'azureContainerInstancesADELoadTestingGatlingDeployment'
  dependsOn: [
    adeAppLoadTestingResourceGroup
  ]
  params: {
    adeAppApiGatewayHostName: adeAppApiGatewayHostName
    adeAppFrontEndHostName: adeAppFrontEndHostName
    adeLoadTestingGatlingContainerGroupName: adeLoadTestingGatlingContainerGroupName
    adeLoadTestingGatlingContainerImageName: adeLoadTestingGatlingContainerImageName
    adeLoadTestingInfluxDbDNSNameLabal: azureContainerInstancesADELoadTestingInfluxDbModule.outputs.influxFqdn
    adeLoadTestingRedisDNSNameLabal: azureContainerInstancesADELoadTestingRedisModule.outputs.redisFqdn
    containerRegistryName: containerRegistryName
    containerRegistryPassword: first(listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords).value
    containerRegistryURL: containerRegistry.properties.loginServer
    location: location
  }
}
