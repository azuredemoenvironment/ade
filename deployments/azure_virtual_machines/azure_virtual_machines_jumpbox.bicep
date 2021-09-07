// parameters
param location string
param adminUserName string
@secure()
param adminPassword string
param logAnalyticsWorkspaceId string
param logAnalyticsWorkspaceCustomerId string
param logAnalyticsWorkspaceKey string
param dataCollectionRuleId string
param managementSubnetId string
param jumpboxPublicIpAddressName string
param jumpboxNICName string
param jumpboxPrivateIpAddress string
param jumpboxName string
param jumpboxOSDiskName string


// variables
var scriptLocation = 'https://raw.githubusercontent.com/joshuawaddell/azure-demo-environment/main/deployments/azure_virtual_machine_jumpbox/jumpboxvm.ps1'
var scriptName = 'jumpboxvm.ps1'
var environmentName = 'production'
var functionName = 'jumpbox'
var costCenterName = 'it'

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

// resource - public ip address - diagnostic settings - jumpbox
resource jumpboxPublicIpAddressDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
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

// resource - network interface - jumpbox
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
            id: managementSubnetId
          }
        }
      }
    ]
  }
}

// resource - network interface - diagnostic settings - jumpbox
resource jumpboxNICDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
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

// resource - virtual machine - jumpbox
resource jumpbox 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: jumpboxName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
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

// resource - data collection rule association - jumpbox
resource jumpboxDataCollectionRuleAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2021-04-01' = {
  scope: jumpbox
  name: '${jumpbox.name}-dataCollectionRuleAssociation'
  properties: {
    description: 'Association of data collection rule for VM Insights Health.'
    dataCollectionRuleId: dataCollectionRuleId
  }
}

// resource - azure monitor windows agent - jumpbox
resource jumpboxAzureMonitorWindowsAgent 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = {
  name: '${jumpbox.name}/AzureMonitorWindowsAgent'
  location: location
  dependsOn: [
    jumpboxDataCollectionRuleAssociation
  ]
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorWindowsAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
  }
}

// resource - guest health windows agent - jumpbox
resource jumpboxGuestHealthWindowsAgent 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = {
  name: '${jumpbox.name}/GuestHealthWindowsAgent'
  location: location
  dependsOn: [
    jumpboxDataCollectionRuleAssociation
  ]
  properties: {
    publisher: 'Microsoft.Azure.Monitor.VirtualMachines.GuestHealth'
    type: 'GuestHealthWindowsAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
  }
}

// resource - dependency agent windows - jumpbox
resource jumpboxDependencyAgent 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = {
  name: '${jumpbox.name}/DependencyAgentWindows'
  location: location
  dependsOn: [
    jumpboxDataCollectionRuleAssociation
  ]
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentWindows'
    typeHandlerVersion: '9.10'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
  }
}

// resource - microsoft monitoring agent - jumpbox
resource jumpboxMicrosoftMonitoringAgent 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = {
  name: '${jumpbox.name}/MMAExtension'
  location: location
  dependsOn: [
    jumpboxDataCollectionRuleAssociation
  ]
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
