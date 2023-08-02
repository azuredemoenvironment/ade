// Parameters
//////////////////////////////////////////////////
@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('The name of the Container Resource Group.')
param containerResourceGroupName string

@description('Function to generate the current time.')
param currentTime string = utcNow()

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The base URI for deployment scripts.')
param scriptsBaseUri string

@description('The name of the Security Resource Group.')
param securityResourceGroupName string

// Variables
//////////////////////////////////////////////////
var sanitizeCurrentTime = replace(replace(currentTime, 'Z', ''), 'T', '')
var scriptLocation = '${scriptsBaseUri}/azure_virtual_machines/adeappinstall.sh'
var scriptName = 'adeappinstall.sh'
var timeStamp = int('${substring(sanitizeCurrentTime, 1, 2)}${substring(sanitizeCurrentTime, 3, 2)}${substring(sanitizeCurrentTime, 5, 2)}${substring(sanitizeCurrentTime, 7, 4)}')

// Variables - Virtual Machine
//////////////////////////////////////////////////
var virtualMachines = [
  {
    name: 'vm-${appEnvironment}-adeapp01'
    scriptLocation: scriptLocation
    timeStamp: timeStamp
    commandToExecute: './${scriptName} "{containerRegistryName}" "${first(containerRegistry.listCredentials().passwords).value}" "${first(appConfig.listKeys().value).connectionString}" "backend" "10.102.2.4" "${scriptsBaseUri}/azure_virtual_machines/nginx.conf"'
  }
  {
    name: 'vm-${appEnvironment}-adeapp02'
    scriptLocation: scriptLocation
    timeStamp: timeStamp
    commandToExecute: './${scriptName} "{containerRegistryName}" "${first(containerRegistry.listCredentials().passwords).value}" "${first(appConfig.listKeys().value).connectionString}" "backend" "10.102.2.4" "${scriptsBaseUri}/azure_virtual_machines/nginx.conf"'
  }
  {
    name: 'vm-${appEnvironment}-adeapp03'
    scriptLocation: scriptLocation
    timeStamp: timeStamp
    commandToExecute: './${scriptName} "{containerRegistryName}" "${first(containerRegistry.listCredentials().passwords).value}" "${first(appConfig.listKeys().value).connectionString}" "backend" "10.102.2.4" "${scriptsBaseUri}/azure_virtual_machines/nginx.conf"'
  }
  {
    name: 'vm-${appEnvironment}-adeweb01'
    scriptLocation: scriptLocation
    timeStamp: timeStamp
    commandToExecute: './${scriptName} "{containerRegistryName}" "${first(containerRegistry.listCredentials().passwords).value}" "${first(appConfig.listKeys().value).connectionString}" "frontend" "10.102.2.4" "${scriptsBaseUri}/azure_virtual_machines/nginx.conf"'
  }
  {
    name: 'vm-${appEnvironment}-adeweb02'
    scriptLocation: scriptLocation
    timeStamp: timeStamp
    commandToExecute: './${scriptName} "{containerRegistryName}" "${first(containerRegistry.listCredentials().passwords).value}" "${first(appConfig.listKeys().value).connectionString}" "frontend" "10.102.2.4" "${scriptsBaseUri}/azure_virtual_machines/nginx.conf"'
  }
  {
    name: 'vm-${appEnvironment}-adeweb03'
    scriptLocation: scriptLocation
    timeStamp: timeStamp
    commandToExecute: './${scriptName} "{containerRegistryName}" "${first(containerRegistry.listCredentials().passwords).value}" "${first(appConfig.listKeys().value).connectionString}" "frontend" "10.102.2.4" "${scriptsBaseUri}/azure_virtual_machines/nginx.conf"'
  }
]

// Variables - Virtual Machine Scale Set
//////////////////////////////////////////////////
var virtualMachineScaleSets = [
  {
    name: 'vmss-${appEnvironment}-adeapp-vmss'
    scriptLocation: scriptLocation
    timeStamp: timeStamp
    commandToExecute: './${scriptName} "{containerRegistryName}" "${first(containerRegistry.listCredentials().passwords).value}" "${first(appConfig.listKeys().value).connectionString}" "backend" "10.102.12.4" "${scriptsBaseUri}/azure_virtual_machines/nginx.conf"'
  }
  {
    name: 'vmss-${appEnvironment}-adeweb-vmss'
    scriptLocation: scriptLocation
    timeStamp: timeStamp
    commandToExecute: './${scriptName} "{containerRegistryName}" "${first(containerRegistry.listCredentials().passwords).value}" "${first(appConfig.listKeys().value).connectionString}" "frontend" "10.102.12.4" "${scriptsBaseUri}/azure_virtual_machines/nginx.conf"'
  }
]

// Variables - Existing Resources
//////////////////////////////////////////////////
var appConfigName = 'appcs-${appEnvironment}'
var containerRegistryName = replace('acr-${appEnvironment}', '-', '')

// Existing Resource - App Configuration
//////////////////////////////////////////////////
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2020-07-01-preview' existing = {
  scope: resourceGroup(securityResourceGroupName)
  name: appConfigName
}

// Resource - Container Registry
//////////////////////////////////////////////////
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' existing = {
  scope: resourceGroup(containerResourceGroupName)
  name: containerRegistryName
}

// Module - Virtual Machine
//////////////////////////////////////////////////
module virtualMachineAppDeploymentModule 'virtual_machine_app_deployment.bicep' = {
  name: 'virtualMachineAppDeployment'
  params: {
    location: location
    virtualMachines: virtualMachines
  }
}

// Module - Virtual Machine Scale Set
//////////////////////////////////////////////////
module virtualMachineScaleSetAppDeploymentModule 'virtual_machine_scale_set_app_deployment.bicep' = {
  name: 'virtualMachineScaleSetAppDeployment'
  params: {
    virtualMachineScaleSets: virtualMachineScaleSets
  }
}
