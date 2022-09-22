// Parameters
//////////////////////////////////////////////////
@description('The name of the Container App.')
param containerAppsName string

@description('The location for all resources.')
param location string

// @description('The name of the admin user of the Azure Container Registry.')
// param containerRegistryName string

// @description('The password of the admin user of the Azure Container Registry.')
// param containerRegistryPassword string

// @description('The URL of the Azure Container Registry.')
// param containerRegistryURL string


@description('The Container Apps Environment Id.')
param contanierAppsEnvironmentId string


// Variables
//////////////////////////////////////////////////
var tags = {
  environment: 'production'
  function: 'containerRegistry'
  costCenter: 'it'
}

// Resource - Azure Container App
resource containerApp 'Microsoft.App/containerapps@2022-01-01-preview' = {
  name: containerAppsName
  kind: 'containerapps'
  location: location
  tags: tags
  properties: {
    configuration: {
      // secrets: [
      //   {
      //     name: 'container-registry-password'
      //     value: containerRegistryPassword
      //   }
      // ]
      // registries: [
      //   {
      //     server: containerRegistryURL
      //     username: containerRegistryName
      //     passwordSecretRef: 'container-registry-password'
      //   }
      // ]
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 80
      }
    }
    template: {
      containers: [
        {
          name: 'containersapp-hello-world'
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          resources: {
            cpu: 1
            memory: '2.0Gi'
          }
        }
      ]
      scale: {
        minReplicas: 0
      }
    }
    managedEnvironmentId: contanierAppsEnvironmentId
  }
}
output fqdn string = containerApp.properties.configuration.ingress.fqdn
