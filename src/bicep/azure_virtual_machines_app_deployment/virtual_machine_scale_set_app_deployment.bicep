// Parameters
//////////////////////////////////////////////////
@description('The connection string from the App Configuration instance.')
param appConfigConnectionString string

@description('The name of the admin user of the Azure Container Registry.')
param containerRegistryName string

@description('The password of the admin user of the Azure Container Registry.')
@secure()
param containerRegistryPassword string

@description('Function to generate the current time.')
param currentTime string = utcNow()

@description('The base URI for deployment scripts.')
param scriptsBaseUri string

@description('The array of properties for Virtual Machine Scale Sets.')
param virtualMachineScaleSets array

// Variables
//////////////////////////////////////////////////
var sanitizeCurrentTime = replace(replace(currentTime, 'Z', ''), 'T', '')
var scriptLocation = '${scriptsBaseUri}/azure_virtual_machines/adeappinstall.sh'
var scriptName = 'adeappinstall.sh'
var timeStamp = int('${substring(sanitizeCurrentTime, 1, 2)}${substring(sanitizeCurrentTime, 3, 2)}${substring(sanitizeCurrentTime, 5, 2)}${substring(sanitizeCurrentTime, 7, 4)}')

// Existing Resource - Virtual Machine Scale Set
//////////////////////////////////////////////////
resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2022-08-01' existing = [for (virtualMachineScaleSet, i) in virtualMachineScaleSets: {
  name: virtualMachineScaleSet.name
}]

// Resource - Custom Script Extension
//////////////////////////////////////////////////
resource adeWebVmCustomScriptExtension 'Microsoft.Compute/virtualMachineScaleSets/extensions@2022-08-01' = [for (virtualMachineScaleSet, i) in virtualMachineScaleSets: {
  parent: vmss[i]
  name: 'CustomScriptextension'
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      skipDos2Unix: true
      timestamp: timeStamp
    }
    protectedSettings: {
      fileUris: [
        scriptLocation
      ]
      commandToExecute: './${scriptName} "${containerRegistryName}" "${containerRegistryPassword}" "${appConfigConnectionString}" "${virtualMachineScaleSet.containerImage}" "${virtualMachineScaleSet.loadBalancerIpAddress}" "${scriptsBaseUri}/azure_virtual_machines/nginx.conf"'
    }
  }
}]
