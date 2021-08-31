// parameters
param defaultPrimaryRegion string
param containerRegistryLoginServer string
@secure()
param containerRegistryLoginUserName string
@secure()
param containerRegistryLoginPassword string
param adeLoadTestingGatlingContainerGroupName string
param adeLoadTestingGatlingContainerImageName string
param adeLoadTestingRedisDNSNameLabal string
param adeLoadTestingInfluxDBDNSNameLabal string
param adeAppFrontEndHostName string
param adeAppApiGatewayHostName string

// variables
var environmentName = 'production'
var functionName = 'aci'
var costCenterName = 'it'

// resource - azure container instance - container group - adeLoadTestingGatling
resource adeLoadTestingGatlingContainerGroup 'Microsoft.ContainerInstance/containerGroups@2021-03-01' = {
  name: adeLoadTestingGatlingContainerGroupName
  location: defaultPrimaryRegion
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
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
              value: '-Dgatling.data.graphite.host=${adeLoadTestingInfluxDBDNSNameLabal} -Dgatling.data.graphite.port=2003 -DwebFrontEndDomain=${adeAppFrontEndHostName} -DwebBackEndDomain=${adeAppApiGatewayHostName} -DredisHost=${adeLoadTestingRedisDNSNameLabal} -DredisPort=6379 -DusersPerSecond=1 -DmaxUsersPerSecond=100 -DoverMinutes=5 -Djsse.enableSNIExtension=false'
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
        server: containerRegistryLoginServer
        username: containerRegistryLoginUserName
        password: containerRegistryLoginPassword
      }
    ]
  }
}
