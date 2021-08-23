// parameters
param location string
param logAnalyticsWorkspaceId string
param logAnalyticsWorkspaceCustomerId string
param logAnalyticsWorkspaceKey string
param adminUserName string
param adminPassword string
param name string
param nicName string
param osDiskName string
param privateIpAddress string
param subnetId string
param tags object
param zone string
param proximityPlacementGroupId string
param acrServerName string = 'acradebrmareus001'
param acrPassword string = 'fH5=cbXIu47TPlW1izjiNP3nkGTNuDOk'
param appConfigConnectionString string = 'Endpoint=https://appcfg-brmar-eus-adeappconfig.azconfig.io;Id=I53x-l0-s0:rcdYDIq6vAqHRtfypsQf;Secret=KlDTpHpU2Lz3Q+AKJiznXvqeWc4kANXZ6d/dBPBpuWQ='
param adeModule string
param now string = utcNow()

// variables
var sanitizedNow = replace(replace(now, 'Z', ''), 'T', '')
var timestamp = int('${substring(sanitizedNow, 3, 2)}${substring(sanitizedNow, 5, 2)}${substring(sanitizedNow, 0, 4)}')

// TODO: this will need to be updated to dev/main/whatever as the file merges
var scriptLocation = 'https://raw.githubusercontent.com/joshuawaddell/azure-demo-environment/brandonmartinez/issue/130-Deploy-ADE-App-to-N-Tier-Virtual-Machines/deployments/azure_virtual_machines/adeappinstall.sh'
var scriptName = 'adeappinstall.sh'

// resource - network interfaces
resource nTierVirtualMachineNIC 'Microsoft.Network/networkInterfaces@2020-08-01' = {
  name: nicName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: privateIpAddress
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

// resource - network interfaces - diagnostic settings
resource ntierVirtualMachineNICDiagnostic 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: nTierVirtualMachineNIC
  name: '${nTierVirtualMachineNIC.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// resource - virtual machine
resource nTierVirtualMachine 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: name
  location: location
  zones: [
    zone
  ]
  tags: tags
  properties: {
    proximityPlacementGroup: {
      id: proximityPlacementGroupId
    }
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: osDiskName
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: name
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nTierVirtualMachineNIC.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

// resource - dependency agent linux
resource nTierVirtualMachineDependencyAgent 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${nTierVirtualMachine.name}/DependencyAgentLinux'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentLinux'
    typeHandlerVersion: '9.5'
    autoUpgradeMinorVersion: true
  }
}

// resource - microsoft monitoring agent
resource nTierVirtualMachineMicrosoftMonitoringAgent 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${nTierVirtualMachine.name}/OMSExtension'
  location: location
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'OmsAgentForLinux'
    typeHandlerVersion: '1.4'
    autoUpgradeMinorVersion: true
    settings: {
      workspaceId: logAnalyticsWorkspaceCustomerId
    }
    protectedSettings: {
      workspaceKey: logAnalyticsWorkspaceKey
    }
  }
}

// resource - custom script extension - jumpbox
resource nTierVirtualMachineCustomScriptExtension 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${name}/CustomScriptextension'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      skipDos2Unix: true
      timestamp: timestamp
    }
    protectedSettings: {
      fileUris: [
        scriptLocation
      ]
      commandToExecute: './${scriptName} "${acrServerName}" "${acrPassword}" "${appConfigConnectionString}" "${adeModule}"'
    }
  }
}
