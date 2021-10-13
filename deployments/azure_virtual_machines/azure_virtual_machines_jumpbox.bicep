// Parameters
//////////////////////////////////////////////////
@description('The password of the admin user.')
@secure()
param adminPassword string

@description('The name of the admin user.')
param adminUserName string

@description('The name of the Jumpbox Virtual Machine.')
param jumpboxName string

@description('The name of the Jumpbox NIC.')
param jumpboxNICName string

@description('The name of the Jumpbox operating system disk.')
param jumpboxOSDiskName string

@description('The private Ip address of the Jumpbox.')
param jumpboxPrivateIpAddress string

@description('The name of the Jumpbox Public Ip Address')
param jumpboxPublicIpAddressName string

@description('The customer Id of the Log Analytics Workspace.')
param logAnalyticsWorkspaceCustomerId string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The Workspace Key of the Log Analytics Workspace.')
param logAnalyticsWorkspaceKey string

@description('The ID of the Management Subnet.')
param managementSubnetId string

// Variables
//////////////////////////////////////////////////
var location = resourceGroup().location
var scriptLocation = 'https://raw.githubusercontent.com/joshuawaddell/azure-demo-environment/main/deployments/azure_virtual_machine_jumpbox/jumpboxvm.ps1'
var scriptName = 'jumpboxvm.ps1'
var tags = {
  environment: 'production'
  function: 'jumpbox'
  costCenter: 'it'
}

// Resource - Public Ip Address - Jumpbox
//////////////////////////////////////////////////
resource jumpboxPublicIpAddress 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: jumpboxPublicIpAddressName
  location: location
  tags: tags
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

// Resource - Public Ip Address - Diagnostic Settings - Jumpbox
//////////////////////////////////////////////////
resource jumpboxPublicIpAddressDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: jumpboxPublicIpAddress
  name: '${jumpboxPublicIpAddress.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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

// Resource - Network Interface - Jumpbox
//////////////////////////////////////////////////
resource jumpboxNIC 'Microsoft.Network/networkInterfaces@2020-08-01' = {
  name: jumpboxNICName
  location: location
  tags: tags
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
            id: managementSubnetId
          }
        }
      }
    ]
  }
}

// Resource - Network Interface - Diagnostic Settings - Jumpbox
//////////////////////////////////////////////////
resource jumpboxNICDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: jumpboxNIC
  name: '${jumpboxNIC.name}-diagnostics'
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

// Resource - Virtual Machine - Jumpbox
//////////////////////////////////////////////////
resource jumpbox 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: jumpboxName
  location: location
  tags: tags
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
      }
    }
  }
}

// Resource - Custom Script Extension - Jumpbox
//////////////////////////////////////////////////
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

// Resource - Dependency Agent Windows - Jumpbox
//////////////////////////////////////////////////
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

// Resource - Microsoft Monitoring Agent - Jumpbox
//////////////////////////////////////////////////
resource jumpboxMicrosoftMonitoringAgent 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${jumpbox.name}/MMAExtension'
  location: location
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'MicrosoftMonitoringAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    settings: {
      workspaceId: logAnalyticsWorkspaceCustomerId
    }
    protectedSettings: {
      workspaceKey: logAnalyticsWorkspaceKey
    }
  }
}
