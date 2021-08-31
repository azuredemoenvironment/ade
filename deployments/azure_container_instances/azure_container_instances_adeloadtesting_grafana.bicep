// parameters
param defaultPrimaryRegion string
param containerRegistryLoginServer string
@secure()
param containerRegistryLoginUserName string
@secure()
param containerRegistryLoginPassword string
param adeLoadTestingGrafanaContainerGroupName string
param adeLoadTestingGrafanaContainerImageName string
param adeLoadTestingInfluxDBDNSNameLabal string

// variables
var environmentName = 'production'
var functionName = 'aci'
var costCenterName = 'it'

// resource - azure container instance - container group - adeLoadTestingGrafana
resource adeLoadTestingGrafanaContainerGroup 'Microsoft.ContainerInstance/containerGroups@2021-03-01' = {
  name: adeLoadTestingGrafanaContainerGroupName
  location: defaultPrimaryRegion
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    containers: [
      {
        name: adeLoadTestingGrafanaContainerGroupName
        properties: {
          image: adeLoadTestingGrafanaContainerImageName
          ports: [
            {
              protocol: 'TCP'
              port: 3000
            }
          ]
          environmentVariables: [
            {
              name: 'INFLUXDB_HOSTNAME'
              value: adeLoadTestingInfluxDBDNSNameLabal
            }
            {
              name: 'INFLUXDB_PORT'
              value: '8086'
            }
          ]
          resources: {
            requests: {
              memoryInGB: 2
              cpu: 1
            }
          }
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: 'Never'
    ipAddress: {
      dnsNameLabel: adeLoadTestingGrafanaContainerGroupName
      type: 'Public'
      ports: [
        {
          protocol: 'TCP'
          port: 3000
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
