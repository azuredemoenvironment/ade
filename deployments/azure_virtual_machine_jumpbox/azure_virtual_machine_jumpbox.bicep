// parameters
param location string = resourceGroup().location
param aliasRegion string
param adminUserName string
param adminPassword string

// variables
var jumpboxPublicIpAddressName = 'pip-ade-${aliasRegion}-jumpbox01'
var jumpboxNICName = 'nic-ade-${aliasRegion}-jumpbox01'
var jumpboxPrivateIpAddress = '10.101.31.4'
var jumpboxName = 'vm-jumpbox01'
var jumpboxOSDiskName = 'osdisk-ade-${aliasRegion}-jumpbox01'
var vmDiagnosticsStorageAccountName = replace('saade${aliasRegion}vmdiags', '-', '')
var scriptLocation = 'https://raw.githubusercontent.com/joshuawaddell/azure-demo-environment/main/deployments/azure_virtual_machine_jumpbox/jumpboxvm.ps1'
var scriptName = 'jumpboxvm.ps1'
var environmentName = 'production'
var functionName = 'jump box'
var costCenterName = 'it'

// existing resources
// log analytics
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(monitorResourceGroupName)
}
// virtual network
var networkingResourceGroupName = 'rg-ade-${aliasRegion}-networking'
var virtualNetwork001Name = 'vnet-ade-${aliasRegion}-001'
var managementSubnetName = 'management'
resource virtualNetwork001 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  name: virtualNetwork001Name
  scope: resourceGroup(networkingResourceGroupName)
  resource managementSubnet 'subnets@2020-07-01' existing = {
    name: managementSubnetName
  }
}

// resource - public ip address - jumpbox
resource jumpboxPublicIpAddress 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: jumpboxPublicIpAddressName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

// resource - public ip address - jump box - diagnostic settings
resource azureBastionPublicIpAddressDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${jumpboxPublicIpAddress.name}-diagnostics'
  scope: jumpboxPublicIpAddress
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'DDoSProtectionNotifications'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'DDoSMitigationFlowLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'DDoSMitigationReports'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
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

// resource - network interface - jump box
resource jumpboxNIC 'Microsoft.Network/networkInterfaces@2020-08-01' = {
  name: jumpboxNICName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: jumpboxPrivateIpAddress
          privateIPAllocationMethod: 'Static'
          publicIPAddress: {
            id: jumpboxPublicIpAddress.id
          }
          subnet: {
            id: virtualNetwork001::managementSubnet.id
          }
        }
      }
    ]
  }
}

// resource - network interface - jump box - diagnostic settings
resource jumpboxNICDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${jumpboxNIC.name}-diagnostics'
  scope: jumpboxNIC
  properties: {
    workspaceId: logAnalyticsWorkspace.id
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

// resource - virtual machine - jumpbox
resource jumpbox 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: jumpboxName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    licenseType: 'Windows_Server'
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter-smalldisk'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: jumpboxOSDiskName
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: jumpboxName
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: jumpboxNIC.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: 'https://${vmDiagnosticsStorageAccountName}.blob.core.windows.net'
      }
    }
  }
}

// resource - custom script extension - jumpbox
resource jumpboxCustomScriptExtension 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${jumpbox.name}/CustomScriptextension'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        scriptLocation
      ]
    }
    protectedSettings: {
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File ${scriptName}'
    }
  }
}

// resource - dependency agent windows - jumpbox
resource jumpboxDependencyAgent 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${jumpbox.name}/DependencyAgentWindows'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentWindows'
    typeHandlerVersion: '9.5'
    autoUpgradeMinorVersion: true
  }
}

// resource - microsoft monitoring agent - jumpbox
resource jumpboxMicrosoftMonitoringAgent 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${jumpbox.name}/MMAExtension'
  location: location
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'MicrosoftMonitoringAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    settings: {
      workspaceId: logAnalyticsWorkspace.properties.customerId
    }
    protectedSettings: {
      workspaceKey: listKeys(resourceId(monitorResourceGroupName, 'Microsoft.OperationalInsights/workspaces/', logAnalyticsWorkspaceName), '2020-10-01').primarySharedKey
    }
  }
}
