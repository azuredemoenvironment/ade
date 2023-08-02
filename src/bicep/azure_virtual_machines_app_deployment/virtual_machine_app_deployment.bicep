// Parameters
//////////////////////////////////////////////////
@description('The location for all resources.')
param location string

@description('The array of properties for Virtual Machines.')
param virtualMachines array

// Existing Resource - Virtual Machine
//////////////////////////////////////////////////
resource vm 'Microsoft.Compute/virtualMachines@2022-08-01' existing = [for (virtualMachine, i) in virtualMachines: {
  name: virtualMachine.name
}]

// Resource - Custom Script Extension
//////////////////////////////////////////////////
resource adeWebVmCustomScriptExtension 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = [for (virtualMachine, i) in virtualMachines: {
  parent: vm[i]
  name: 'CustomScriptextension'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      skipDos2Unix: true
      timestamp: virtualMachine.timeStamp
    }
    protectedSettings: {
      fileUris: [
        virtualMachine.scriptLocation
      ]
      commandToExecute: virtualMachine.commandToExecute
    }
  }
}]
