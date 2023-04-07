// Parameters
//////////////////////////////////////////////////
@description('The password of the admin user.')
@secure()
param adminPassword string

@description('The name of the admin user.')
param adminUserName string

@description('The ID of the Diagnostics Storage Account.')
param diagnosticsStorageAccountId string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The name of the Jumpbox Virtual Machine.')
param jumpboxName string

@description('The name of the Jumpbox NIC.')
param jumpboxNICName string

@description('The name of the Jumpbox operating system disk.')
param jumpboxOSDiskName string

@description('The name of the Jumpbox Public Ip Address')
param jumpboxPublicIpAddressName string

@description('The location for all resources.')
param location string

@description('The customer Id of the Log Analytics Workspace.')
param logAnalyticsWorkspaceCustomerId string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The Workspace Key of the Log Analytics Workspace.')
param logAnalyticsWorkspaceKey string

@description('The ID of the Management Subnet.')
param managementSubnetId string

@description('The base URI for deployment scripts.')
param scriptsBaseUri string

@description('The list of Resource tags')
param tags object

// Variables
//////////////////////////////////////////////////
var scriptLocation = '${scriptsBaseUri}/azure_virtual_machines/jumpboxvm.ps1'
var scriptName = 'jumpboxvm.ps1'

// Resource - Public Ip Address
//////////////////////////////////////////////////
resource jumpboxPublicIpAddress 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
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

// Resource - Public Ip Address - Diagnostic Settings
//////////////////////////////////////////////////
resource jumpboxPublicIpAddressDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: jumpboxPublicIpAddress
  name: '${jumpboxPublicIpAddress.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'DDoSProtectionNotifications'
        enabled: true
      }
      {
        category: 'DDoSMitigationFlowLogs'
        enabled: true
      }
      {
        category: 'DDoSMitigationReports'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// Resource - Network Interface
//////////////////////////////////////////////////
resource jumpboxNIC 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: jumpboxNICName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
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

// Resource - Network Interface - Diagnostic Settings
//////////////////////////////////////////////////
resource jumpboxNICDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: jumpboxNIC
  name: '${jumpboxNIC.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// Resource - Virtual Machine
//////////////////////////////////////////////////
resource jumpbox 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: jumpboxName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
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
        sku: '2022-Datacenter-smalldisk'
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

// Resource - Custom Script Extension
//////////////////////////////////////////////////
resource jumpboxCustomScriptExtension 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = {
  parent: jumpbox
  name: 'CustomScriptextension'
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

// Resource - Dependency Agent Windows
//////////////////////////////////////////////////
resource jumpboxDependencyAgent 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = {
  parent: jumpbox
  name: 'DependencyAgentWindows'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentWindows'
    typeHandlerVersion: '9.5'
    autoUpgradeMinorVersion: true
  }
}

// Resource - Microsoft Monitoring Agent
//////////////////////////////////////////////////
resource jumpboxMicrosoftMonitoringAgent 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = {
  parent: jumpbox
  name: 'MMAExtension'
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

// Resource - Guest Configuration
//////////////////////////////////////////////////
resource jumpboxGuestConfiguration 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = {
  parent: jumpbox
  name: 'AzurePolicyforWindows'
  location: location
  properties: {
    publisher: 'Microsoft.GuestConfiguration'
    type: 'ConfigurationforWindows'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
  }
}
