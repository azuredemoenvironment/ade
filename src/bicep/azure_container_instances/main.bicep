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

// Variables - Container Registry Credentials
//////////////////////////////////////////////////
var imageRegistryCredentials = [
  {
    server: containerRegistry.properties.loginServer
    username: containerRegistry.name
    password: first(containerRegistry.listCredentials().passwords).value
  }
]

// Variables - Container Instance - Redis
//////////////////////////////////////////////////
var redisContainerGroupName = 'ci-${appEnvironment}-loadtesting-redis'
var redisContainerImageName = '${containerRegistry.properties.loginServer}/ade-loadtesting-redis:latest'
var redisContainers = [
  {
    name: redisContainerGroupName
    properties: {
      image: redisContainerImageName
      ports: redisPorts
      environmentVariables: []
      resources: {
        requests: {
          memoryInGB: 2
          cpu: 2
        }
      }
    }    
  }
]
var redisPorts = [
  {
    protocol: 'TCP'
    port: 6379
  }
]
var redisContainerInstanceProperties = {
  name: redisContainerGroupName
  containers: redisContainers
  osType: 'Linux'
  restartPolicy: 'Never'
  dnsNameLabel: redisContainerGroupName
  ipAddressType: 'Public'
  ports: redisPorts
  imageRegistryCredentials: imageRegistryCredentials
}

// Variables - Container Instance - Influx Db
//////////////////////////////////////////////////
var influxDbContainerGroupName = 'ci-${appEnvironment}-loadtesting-influxdb'
var influxDbContainerImageName = '${containerRegistry.properties.loginServer}/ade-loadtesting-influxdb:latest'
var influxDbContainers = [
  {
    name: influxDbContainerGroupName
    properties: {
      image: influxDbContainerImageName
      ports: influxDbPorts
      environmentVariables: []
      resources: {
        requests: {
          memoryInGB: 2
          cpu: 2
        }
      }
    }    
  }
]
var influxDbPorts = [
  {
    protocol: 'TCP'
    port: 8083
  }
  {
    protocol: 'TCP'
    port: 8086
  }
  {
    protocol: 'TCP'
    port: 2003
  }
]
var influxDbContainerInstanceProperties = {
  name: influxDbContainerGroupName
  containers: influxDbContainers
  osType: 'Linux'
  restartPolicy: 'Never'
  dnsNameLabel: influxDbContainerGroupName
  ipAddressType: 'Public'
  ports: influxDbPorts
  imageRegistryCredentials: imageRegistryCredentials
}

// Variables - Container Instance - Grafana
//////////////////////////////////////////////////
var grafanaContainerGroupName = 'ci-${appEnvironment}-loadtesting-grafana'
var grafanaContainerImageName = '${containerRegistry.properties.loginServer}/ade-loadtesting-grafana:latest'
var grafanaContainers = [
  {
    name: grafanaContainerGroupName
    properties: {
      image: grafanaContainerImageName
      ports: grafanaPorts
      environmentVariables: grafanaEnvironmentVariables
      resources: {
        requests: {
          memoryInGB: 2
          cpu: 2
        }
      }
    }    
  }
]
var grafanaPorts = [
  {
    protocol: 'TCP'
    port: 3000
  }
]
var grafanaEnvironmentVariables = [
  {
    name: 'INFLUXDB_HOSTNAME'
    value: influxDbContainerInstanceModule.outputs.containerGroupFqdn
  }
  {
    name: 'INFLUXDB_PORT'
    value: '8086'
  }
]
var grafanaContainerInstanceProperties = {
  name: grafanaContainerGroupName
  containers: grafanaContainers
  osType: 'Linux'
  restartPolicy: 'Never'
  dnsNameLabel: grafanaContainerGroupName
  ipAddressType: 'Public'
  ports: grafanaPorts
  imageRegistryCredentials: imageRegistryCredentials
}

// Variables - Container Instance - Gatling
//////////////////////////////////////////////////
var adeAppApiGatewayHostName = 'ade-apigateway.${rootDomainName}'
var adeAppFrontEndHostName = 'ade-frontend.${rootDomainName}'
var gatlingContainerGroupName = 'ci-${appEnvironment}-loadtesting-gatling'
var gatlingContainerImageName = '${containerRegistry.properties.loginServer}/ade-loadtesting-gatling:latest'
var gatlingContainers = [
  {
    name: gatlingContainerGroupName
    properties: {
      image: gatlingContainerImageName
      ports: gatlingPorts
      environmentVariables: gatlingEnvironmentVariables
      resources: {
        requests: {
          memoryInGB: 4
          cpu: 4
        }
      }
    }    
  }
]
var gatlingPorts = [
  {
    protocol: 'TCP'
    port: 80
  }
]
var gatlingEnvironmentVariables = [
  {
    name: 'JAVA_OPTS'
    value: '-Dgatling.data.graphite.host=${influxDbContainerInstanceModule.outputs.containerGroupFqdn} -Dgatling.data.graphite.port=2003 -DwebFrontEndDomain=${adeAppFrontEndHostName} -DwebBackEndDomain=${adeAppApiGatewayHostName} -DredisHost=${redisContainerInstanceModule.outputs.containerGroupFqdn} -DredisPort=6379 -DusersPerSecond=1 -DmaxUsersPerSecond=100 -DoverMinutes=5 -Djsse.enableSNIExtension=false'
  }
]
var gatlingContainerInstanceProperties = {
  name: gatlingContainerGroupName
  containers: gatlingContainers
  osType: 'Linux'
  restartPolicy: 'Never'
  dnsNameLabel: gatlingContainerGroupName
  ipAddressType: 'Public'
  ports: gatlingPorts
  imageRegistryCredentials: imageRegistryCredentials
}


// Variables - Existing Resources
//////////////////////////////////////////////////
var containerRegistryName = replace('acr-${appEnvironment}', '-', '')

// Existing Resource - Container Registry
//////////////////////////////////////////////////
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' existing = {
  scope: resourceGroup(containerResourceGroupName)
  name: containerRegistryName
}

// Module - Container Instance - Redis
//////////////////////////////////////////////////
module redisContainerInstanceModule 'container_instance.bicep' = {
  name: 'redisContainerInstanceDeployment'
  params: {
    containerGroupProperties: redisContainerInstanceProperties
    location: location
    tags: tags
  }
}

// Module - Container Instance - Influx Db
//////////////////////////////////////////////////
module influxDbContainerInstanceModule 'container_instance.bicep' = {
  name: 'influxDbContainerInstanceDeployment'
  params: {
    containerGroupProperties: influxDbContainerInstanceProperties
    location: location
    tags: tags
  }
}

// Module - Container Instance - Grafana
//////////////////////////////////////////////////
module grafanaContainerInstanceModule 'container_instance.bicep' = {
  name: 'grafanaContainerInstanceDeployment'
  params: {
    containerGroupProperties: grafanaContainerInstanceProperties
    location: location
    tags: tags
  }
}

// Module - Container Instance - Gatling
//////////////////////////////////////////////////
module gatlingContainerInstanceModule 'container_instance.bicep' = {
  name: 'gatlingContainerInstanceDeployment'
  params: {
    containerGroupProperties: gatlingContainerInstanceProperties
    location: location
    tags: tags
  }
}
