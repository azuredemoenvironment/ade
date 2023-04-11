// Parameters
//////////////////////////////////////////////////
@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('The name of the Container Resource Group.')
param containerResourceGroupName string

@description('The current date.')
param currentDate string = utcNow('yyyy-MM-dd')

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of the owner of the deployment.')
param ownerName string

@description('The value for Root Domain Name.')
param rootDomainName string

// Variables
//////////////////////////////////////////////////
var tags = {
  deploymentDate: currentDate
  owner: ownerName
}

// Variables - Container Instances
//////////////////////////////////////////////////
var containerInstances = [
  {
    name: 'ci-${appEnvironment}-adeloadtesting-redis'
    containers: [
      {
        name: 'ci-${appEnvironment}-adeloadtesting-redis'
        image: '${containerRegistry.properties.loginServer}/ade-loadtesting-redis:latest'
        ports: [
          {
            protocol: 'TCP'
            port: 6379
          }
        ]
        memoryInGB: 2
        cpu: 2
      }
    ]
    osType: 'Linux'
    restartPolicy: 'Never'
    dnsNameLabel: 'ci-${appEnvironment}-adeloadtesting-redis'
    ipAddressType: 'Public'
    ports: [
      {
        protocol: 'TCP'
        port: 6379
      }
    ]
    imageRegistryCredentials: [
      {
        server: containerRegistry.properties.loginServer
        username: containerRegistry.name
        password: first(containerRegistry.listCredentials().passwords).value
      }
    ] 
  }
]

var containerInstanceContainers = [
  {
    name: 'ci-${appEnvironment}-adeloadtesting-redis'
    image: '${containerRegistry.properties.loginServer}/ade-loadtesting-redis:latest'
    ports: containerInstancePorts
  }
]

var containerInstancePorts = [
  {
    protocol: 'TCP'
    port: 6379
  }
]





module containerInstanceModule 'container_instance.bicep' = {
  name: 'containerInstanceDeployment'
  params: {
    containerInstances: containerInstances
    location: location
    tags: tags
  }
}

// var adeAppApiGatewayHostName = 'ade-apigateway.${rootDomainName}'
// var adeAppFrontEndHostName = 'ade-frontend.${rootDomainName}'
// var adeLoadTestingGatlingContainerGroupName = 'ci-${appEnvironment}-adeloadtesting-gatling'
// var adeLoadTestingGatlingContainerImageName = '${containerRegistry.properties.loginServer}/ade-loadtesting-gatling:latest'
// /var adeLoadTestingGrafanaContainerGroupName = 'ci-${appEnvironment}-adeloadtesting-grafana'
// var adeLoadTestingGrafanaContainerImageName = '${containerRegistry.properties.loginServer}/ade-loadtesting-grafana:latest'
// /var adeLoadTestingInfluxDbContainerGroupName = 'ci-${appEnvironment}-adeloadtesting-influxdb'
// var adeLoadTestingInfluxDbContainerImageName = '${containerRegistry.properties.loginServer}/ade-loadtesting-influxdb:latest'
// /var adeLoadTestingRedisContainerGroupName = 'ci-${appEnvironment}-adeloadtesting-redis'
// var adeLoadTestingRedisContainerImageName = '${containerRegistry.properties.loginServer}/ade-loadtesting-redis:latest'

// Variables - Existing Resources
//////////////////////////////////////////////////
var containerRegistryName = replace('acr-${appEnvironment}', '-', '')

// Existing Resource - Container Registry
//////////////////////////////////////////////////
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' existing = {
  scope: resourceGroup(containerResourceGroupName)
  name: containerRegistryName
}

// Module - Azure Container Instances - Redis
//////////////////////////////////////////////////
// module aciLoadTestingRedisModule 'aci_loadtesting_redis.bicep' = {
//   name: 'aciLoadTestingRedisDeployment'
//   params: {
//     adeLoadTestingRedisContainerGroupName: adeLoadTestingRedisContainerGroupName
//     adeLoadTestingRedisContainerImageName: adeLoadTestingRedisContainerImageName
//     containerRegistryName: containerRegistry.name
//     containerRegistryPassword: first(listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords).value
//     containerRegistryURL: containerRegistry.properties.loginServer
//     location: location
//     tags: tags
//   }
// }

// Module - Azure Container Instances - InfluxDb
//////////////////////////////////////////////////
// module aciLoadTestingInfluxDbModule 'aci_loadtesting_influxdb.bicep' = {
//   name: 'aciLoadTestingInfluxDbDeployment'
//   params: {
//     adeLoadTestingInfluxDbContainerGroupName: adeLoadTestingInfluxDbContainerGroupName
//     adeLoadTestingInfluxDbContainerImageName: adeLoadTestingInfluxDbContainerImageName
//     containerRegistryName: containerRegistry.name
//     containerRegistryPassword: first(listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords).value
//     containerRegistryURL: containerRegistry.properties.loginServer
//     location: location
//     tags: tags
//   }
// }

// Module - Azure Container Instances - Grafana
//////////////////////////////////////////////////
// module aciLoadTestingGrafanaModule 'aci_loadtesting_grafana.bicep' = {
//   name: 'aciLoadTestingGrafanaDeployment'
//   params: {
//     adeLoadTestingGrafanaContainerGroupName: adeLoadTestingGrafanaContainerGroupName
//     adeLoadTestingGrafanaContainerImageName: adeLoadTestingGrafanaContainerImageName
//     adeLoadTestingInfluxDbDNSNameLabel: aciLoadTestingInfluxDbModule.outputs.influxFqdn
//     containerRegistryName: containerRegistry.name
//     containerRegistryPassword: first(listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords).value
//     containerRegistryURL: containerRegistry.properties.loginServer
//     location: location
//     tags: tags
//   }
// }

// Module - Azure Container Instances - Gatling
//////////////////////////////////////////////////
// module aciLoadTestingGatlingModule 'aci_loadtesting_gatling.bicep' = {
//   name: 'aciLoadTestingGatlingDeployment'
//   params: {
//     adeAppApiGatewayHostName: adeAppApiGatewayHostName
//     adeAppFrontEndHostName: adeAppFrontEndHostName
//     adeLoadTestingGatlingContainerGroupName: adeLoadTestingGatlingContainerGroupName
//     adeLoadTestingGatlingContainerImageName: adeLoadTestingGatlingContainerImageName
//     adeLoadTestingInfluxDbDNSNameLabel: aciLoadTestingInfluxDbModule.outputs.influxFqdn
//     adeLoadTestingRedisDNSNameLabel: aciLoadTestingRedisModule.outputs.redisFqdn
//     containerRegistryName: containerRegistry.name
//     containerRegistryPassword: first(listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords).value
//     containerRegistryURL: containerRegistry.properties.loginServer
//     location: location
//     tags: tags
//   }
// }
