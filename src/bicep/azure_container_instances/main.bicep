// Parameters
//////////////////////////////////////////////////
@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('The name of the Container Resource Group.')
param containerResourceGroupName string

@description('The date of the resource deployment.')
param deploymentDate string = utcNow('yyyy-MM-dd')

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of the owner of the deployment.')
param ownerName string

@description('The value for Root Domain Name.')
param rootDomainName string

// Variables
//////////////////////////////////////////////////
var adeAppApiGatewayHostName = 'ade-apigateway.${rootDomainName}'
var adeAppFrontEndHostName = 'ade-frontend.${rootDomainName}'
var adeLoadTestingGatlingContainerGroupName = 'ci-${appEnvironment}-adeloadtesting-gatling'
var adeLoadTestingGatlingContainerImageName = '${containerRegistry.properties.loginServer}/ade-loadtesting-gatling:latest'
var adeLoadTestingGrafanaContainerGroupName = 'ci-${appEnvironment}-adeloadtesting-grafana'
var adeLoadTestingGrafanaContainerImageName = '${containerRegistry.properties.loginServer}/ade-loadtesting-grafana:latest'
var adeLoadTestingInfluxDbContainerGroupName = 'ci-${appEnvironment}-adeloadtesting-influxdb'
var adeLoadTestingInfluxDbContainerImageName = '${containerRegistry.properties.loginServer}/ade-loadtesting-influxdb:latest'
var adeLoadTestingRedisContainerGroupName = 'ci-${appEnvironment}-adeloadtesting-redis'
var adeLoadTestingRedisContainerImageName = '${containerRegistry.properties.loginServer}/ade-loadtesting-redis:latest'
var tags = {
  deploymentDate: deploymentDate
  owner: ownerName
}

// Existing Resource - Container Registry
//////////////////////////////////////////////////
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' existing = {
  scope: resourceGroup(containerResourceGroupName)
  name: replace('acr-${appEnvironment}-001', '-', '')
}

// Module - Azure Container Instances - Redis
//////////////////////////////////////////////////
module azureContainerInstancesADELoadTestingRedisModule 'aci_loadtesting_redis.bicep' = {
  name: 'azureContainerInstancesADELoadTestingRedisDeployment'
  params: {
    adeLoadTestingRedisContainerGroupName: adeLoadTestingRedisContainerGroupName
    adeLoadTestingRedisContainerImageName: adeLoadTestingRedisContainerImageName
    containerRegistryName: containerRegistry.name
    containerRegistryPassword: first(listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords).value
    containerRegistryURL: containerRegistry.properties.loginServer
    location: location
    tags: tags
  }
}

// Module - Azure Container Instances - InfluxDb
//////////////////////////////////////////////////
module azureContainerInstancesADELoadTestingInfluxDbModule 'azure_container_instances_adeloadtesting_influxdb.bicep' = {
  name: 'azureContainerInstancesADELoadTestingInfluxDbDeployment'
  params: {
    adeLoadTestingInfluxDbContainerGroupName: adeLoadTestingInfluxDbContainerGroupName
    adeLoadTestingInfluxDbContainerImageName: adeLoadTestingInfluxDbContainerImageName
    containerRegistryName: containerRegistry.name
    containerRegistryPassword: first(listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords).value
    containerRegistryURL: containerRegistry.properties.loginServer
    location: location
  }
}

// Module - Azure Container Instances - Grafana
//////////////////////////////////////////////////
module azureContainerInstancesADELoadTestingGrafanaModule 'azure_container_instances_adeloadtesting_grafana.bicep' = {
  name: 'azureContainerInstancesADELoadTestingGrafanaDeployment'
  params: {
    adeLoadTestingGrafanaContainerGroupName: adeLoadTestingGrafanaContainerGroupName
    adeLoadTestingGrafanaContainerImageName: adeLoadTestingGrafanaContainerImageName
    adeLoadTestingInfluxDbDNSNameLabel: azureContainerInstancesADELoadTestingInfluxDbModule.outputs.influxFqdn
    containerRegistryName: containerRegistry.name
    containerRegistryPassword: first(listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords).value
    containerRegistryURL: containerRegistry.properties.loginServer
    location: location
  }
}

// Module - Azure Container Instances - Gatling
//////////////////////////////////////////////////
module azureContainerInstancesADELoadTestingGatlingModule 'azure_container_instances_adeloadtesting_gatling.bicep' = {
  name: 'azureContainerInstancesADELoadTestingGatlingDeployment'
  params: {
    adeAppApiGatewayHostName: adeAppApiGatewayHostName
    adeAppFrontEndHostName: adeAppFrontEndHostName
    adeLoadTestingGatlingContainerGroupName: adeLoadTestingGatlingContainerGroupName
    adeLoadTestingGatlingContainerImageName: adeLoadTestingGatlingContainerImageName
    adeLoadTestingInfluxDbDNSNameLabel: azureContainerInstancesADELoadTestingInfluxDbModule.outputs.influxFqdn
    adeLoadTestingRedisDNSNameLabel: azureContainerInstancesADELoadTestingRedisModule.outputs.redisFqdn
    containerRegistryName: containerRegistry.name
    containerRegistryPassword: first(listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords).value
    containerRegistryURL: containerRegistry.properties.loginServer
    location: location
  }
}
