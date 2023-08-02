// Parameters
//////////////////////////////////////////////////
@description('The array of properties for Virtual Machine Scale Sets.')
param virtualMachineScaleSets array

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
      timestamp: virtualMachineScaleSet.timeStamp
    }
    protectedSettings: {
      fileUris: [
        virtualMachineScaleSet.scriptLocation
      ]
      commandToExecute: virtualMachineScaleSet.commandToExecute
    }
  }
}]
