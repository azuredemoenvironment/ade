// Parameters
//////////////////////////////////////////////////
@description('The private Ip address of the ADE App Vm Load Balancer.')
param adeAppVmLoadBalancerPrivateIpAddress string

@description('The array of properties for the ADE Web Virtual Machines.')
param adeWebVirtualMachines array

@description('The ID of the ADE Web Virtual Machine subnet.')
param adeWebVmSubnetId string

@description('The password of the admin user.')
@secure()
param adminPassword string

@description('The name of the admin user.')
param adminUserName string

@description('The connection string from the App Configuration instance.')
param appConfigConnectionString string

@description('The name of the admin user of the Azure Container Registry.')
param containerRegistryName string

@description('The password of the admin user of the Azure Container Registry.')
param containerRegistryPassword string

@description('Function to generate the current time.')
param currentTime string = utcNow()

@description('The customer Id of the Log Analytics Workspace.')
param logAnalyticsWorkspaceCustomerId string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The Workspace Key of the Log Analytics Workspace.')
param logAnalyticsWorkspaceKey string

@description('The base URI for deployment scripts.')
param scriptsBaseUri string

// Variables
//////////////////////////////////////////////////
var location = resourceGroup().location
var sanitizeCurrentTime = replace(replace(currentTime, 'Z', ''), 'T', '')
var scriptLocation = '${scriptsBaseUri}/azure_virtual_machines/adeappinstall.sh'
var scriptName = 'adeappinstall.sh'
var tags = {
  environment: 'production'
  function: 'adeWebVm'
  costCenter: 'it'
}
var timeStamp = int('${substring(sanitizeCurrentTime, 1, 2)}${substring(sanitizeCurrentTime, 3, 2)}${substring(sanitizeCurrentTime, 5, 2)}${substring(sanitizeCurrentTime, 7, 4)}')

// Resource - Network Interface - ADE Web Vm
//////////////////////////////////////////////////
resource adeWebVmNic 'Microsoft.Network/networkInterfaces@2020-08-01' = [for (adeWebVirtualMachine, i) in adeWebVirtualMachines: {
  name: adeWebVirtualMachine.nicName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: adeWebVmSubnetId
          }
        }
      }
    ]
  }
}]

// Resource - Network Interface - Diagnostic Settings
//////////////////////////////////////////////////
resource adeWebVmNicDiagnosticSetting 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = [for (adeWebVirtualMachine, i) in adeWebVirtualMachines: {
  scope: adeWebVmNic[i]
  name: '${adeWebVirtualMachine.nicName}-diagnostics'
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
}]

// Resource - Virtual Machine
//////////////////////////////////////////////////
resource adeWebVm 'Microsoft.Compute/virtualMachines@2020-12-01' = [for (adeWebVirtualMachine, i) in adeWebVirtualMachines: {
  name: adeWebVirtualMachine.name
  location: location
  zones: [
    adeWebVirtualMachine.availabilityZone
  ]
  tags: tags
  properties: {
    proximityPlacementGroup: {
      id: adeWebVirtualMachine.proximityPlacementGroupId
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
        name: adeWebVirtualMachine.osDiskName
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: adeWebVirtualMachine.name
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: adeWebVmNic[i].id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}]

// Resource - Dependency Agent Linux
//////////////////////////////////////////////////
resource adeWebVmDependencyAgent 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = [for (adeWebVirtualMachine, i) in adeWebVirtualMachines: {
  name: '${adeWebVm[i].name}/DependencyAgentLinux'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentLinux'
    typeHandlerVersion: '9.5'
    autoUpgradeMinorVersion: true
  }
}]

// Resource - Microsoft Monitoring Agent
//////////////////////////////////////////////////
resource adeWebVmMicrosoftMonitoringAgent 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = [for (adeWebVirtualMachine, i) in adeWebVirtualMachines: {
  name: '${adeWebVm[i].name}/OMSExtension'
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
}]

// Resource - Custom Script Extension - ADE Web Vmss
//////////////////////////////////////////////////
resource adeWebVmCustomScriptExtension 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = [for (adeWebVirtualMachine, i) in adeWebVirtualMachines: {
  name: '${adeWebVm[i].name}/CustomScriptextension'
  location: location
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
      commandToExecute: './${scriptName} "${containerRegistryName}" "${containerRegistryPassword}" "${appConfigConnectionString}" "${adeWebVirtualMachine.adeModule}" "${adeAppVmLoadBalancerPrivateIpAddress}" "${scriptsBaseUri}/azure_virtual_machines/nginx.conf"'
    }
  }
}]
