// Parameters
//////////////////////////////////////////////////
@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('The name of the Container Resource Group.')
param containerResourceGroupName string

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The base URI for deployment scripts.')
param scriptsBaseUri string

@description('The name of the Security Resource Group.')
param securityResourceGroupName string

// Variable Arrays
//////////////////////////////////////////////////
var backendServices = [
  {
    name: 'DataIngestorService'
    port: 5000
  }
  {
    name: 'DataReporterService'
    port: 5001
  }
  {
    name: 'UserService'
    port: 5002
  }
  {
    name: 'EventIngestorService'
    port: 5003
  }
]
var virtualMachines = [
  {
    name: 'vm-${appEnvironment}-adeapp01'
    containerImage: 'backend'
    loadBalancerIpAddress: '10.102.2.4'
  }
  {
    name: 'vm-${appEnvironment}-adeapp02'
    containerImage: 'backend'
    loadBalancerIpAddress: '10.102.2.4'
  }
  {
    name: 'vm-${appEnvironment}-adeapp03'
    containerImage: 'backend'
    loadBalancerIpAddress: '10.102.2.4'
  }
  {
    name: 'vm-${appEnvironment}-adeweb01'
    containerImage: 'frontend'
    loadBalancerIpAddress: '10.102.2.4'
  }
  {
    name: 'vm-${appEnvironment}-adeweb02'
    containerImage: 'frontend'
    loadBalancerIpAddress: '10.102.2.4'
  }
  {
    name: 'vm-${appEnvironment}-adeweb03'
    containerImage: 'frontend'
    loadBalancerIpAddress: '10.102.2.4'
  }
]
var virtualMachineScaleSets = [
  {
    name: 'vmss-${appEnvironment}-adeapp-vmss'
    containerImage: 'backend'
    loadBalancerIpAddress: '10.102.12.4'
  }
  {
    name: 'vmss-${appEnvironment}-adeweb-vmss'
    containerImage: 'frontend'
    loadBalancerIpAddress: '10.102.12.4'
  }
]

// Existing Resource - App Config
//////////////////////////////////////////////////
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2020-07-01-preview' existing = {
  scope: resourceGroup(securityResourceGroupName)
  name: 'appcs-${appEnvironment}'
}

// Resource - Container Registry
//////////////////////////////////////////////////
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' existing = {
  scope: resourceGroup(containerResourceGroupName)
  name: replace('acr-${appEnvironment}', '-', '')
}

// Module - Virtual Machine
//////////////////////////////////////////////////
module virtualMachineAppDeploymentModule 'virtual_machine_app_deployment.bicep' = {
  name: 'virtualMachineAppDeployment'
  params: {
    appConfigConnectionString: first(listKeys(appConfig.id, appConfig.apiVersion).value).connectionString
    containerRegistryName: containerRegistry.name
    containerRegistryPassword: first(listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords).value
    location: location
    scriptsBaseUri: scriptsBaseUri
    virtualMachines: virtualMachines
  }
}

// Module - Virtual Machine Scale Set
//////////////////////////////////////////////////
module virtualMachineScaleSetAppDeploymentModule 'virtual_machine_scale_set_app_deployment.bicep' = {
  name: 'virtualMachineScaleSetAppDeployment'
  params: {
    appConfigConnectionString: first(listKeys(appConfig.id, appConfig.apiVersion).value).connectionString
    containerRegistryName: containerRegistry.name
    containerRegistryPassword: first(listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords).value
    scriptsBaseUri: scriptsBaseUri
    virtualMachineScaleSets: virtualMachineScaleSets
  }
}

// Module - App Configuration - Virtual Machines
//////////////////////////////////////////////////
module appConfigVirtualMachines 'virtual_machine_app_config.bicep' = {
  scope: resourceGroup(securityResourceGroupName)
  name: 'appConfigBackendServicesDeployment'
  params: {
    appConfigName: appConfig.name
    backendServices: backendServices
  }
}
