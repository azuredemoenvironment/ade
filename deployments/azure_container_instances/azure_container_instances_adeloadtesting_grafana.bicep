// Parameters
//////////////////////////////////////////////////
@description('The name of the Grafana Container Group.')
param adeLoadTestingGrafanaContainerGroupName string

@description('The name of the Grafana Container Image.')
param adeLoadTestingGrafanaContainerImageName string

@description('The DNS Name Labl of the Influx Db Container Group.')
param adeLoadTestingInfluxDbDNSNameLabal string

@description('The name of the admin user of the Azure Container Registry.')
param containerRegistryName string

@description('The password of the admin user of the Azure Container Registry.')
param containerRegistryPassword string

@description('The URL of the Azure Container Registry.')
param containerRegistryURL string

@description('The region location of deployment.')
param location string = resourceGroup().location

// Variables
//////////////////////////////////////////////////
var tags = {
  environment: 'production'
  function: 'aci'
  costCenter: 'it'
}

// Resource - Azure Container Instance - Container Group - Grafana
//////////////////////////////////////////////////
resource adeLoadTestingGrafanaContainerGroup 'Microsoft.ContainerInstance/containerGroups@2021-03-01' = {
  name: adeLoadTestingGrafanaContainerGroupName
  location: location
  tags: tags
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
              value: adeLoadTestingInfluxDbDNSNameLabal
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
        server: containerRegistryURL
        username: containerRegistryName
        password: containerRegistryPassword
      }
    ]
  }
}
