// Parameters
//////////////////////////////////////////////////
@description('The host name of the  App Frontend.')
param adeAppFrontEndHostName string

@description('The host name of the  App Api Gateway.')
param adeAppApiGatewayHostName string

@description('The name of the Gatling Container Group.')
param adeLoadTestingGatlingContainerGroupName string

@description('The name of the Gatling Container Image.')
param adeLoadTestingGatlingContainerImageName string

@description('The DNS Name Label of the Influx Db Container Group.')
param adeLoadTestingRedisDNSNameLabel string

@description('The DNS Name Label of the Influx Db Container Group.')
param adeLoadTestingInfluxDbDNSNameLabel string

@description('The name of the admin user of the Azure Container Registry.')
param containerRegistryName string

@description('The password of the admin user of the Azure Container Registry.')
@secure()
param containerRegistryPassword string

@description('The URL of the Azure Container Registry.')
param containerRegistryURL string

@description('The location for all resources.')
param location string

@description('The list of resource tags.')
param tags object

// Resource - Azure Container Instance - Container Group - Gatling
//////////////////////////////////////////////////
resource adeLoadTestingGatlingContainerGroup 'Microsoft.ContainerInstance/containerGroups@2021-03-01' = {
  name: adeLoadTestingGatlingContainerGroupName
  location: location
  tags: tags
  properties: {
    containers: [
      {
        name: adeLoadTestingGatlingContainerGroupName
        properties: {
          image: adeLoadTestingGatlingContainerImageName
          ports: [
            {
              protocol: 'TCP'
              port: 80
            }
          ]
          environmentVariables: [
            {
              name: 'JAVA_OPTS'
              value: '-Dgatling.data.graphite.host=${adeLoadTestingInfluxDbDNSNameLabel} -Dgatling.data.graphite.port=2003 -DwebFrontEndDomain=${adeAppFrontEndHostName} -DwebBackEndDomain=${adeAppApiGatewayHostName} -DredisHost=${adeLoadTestingRedisDNSNameLabel} -DredisPort=6379 -DusersPerSecond=1 -DmaxUsersPerSecond=100 -DoverMinutes=5 -Djsse.enableSNIExtension=false'
            }
          ]
          resources: {
            requests: {
              memoryInGB: 4
              cpu: 4
            }
          }
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: 'Never'
    ipAddress: {
      dnsNameLabel: adeLoadTestingGatlingContainerGroupName
      type: 'Public'
      ports: [
        {
          protocol: 'TCP'
          port: 80
        }
      ]
    }
    imageRegistryCredentials: [
      {
        server: containerRegistryURL
        username: containerRegistryName
        password: containerRegistryPassword
      }
    ]
  }
}
