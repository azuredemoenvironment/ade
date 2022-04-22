// Parameters
//////////////////////////////////////////////////
@description('The ID of the ADE App Vmss Load Balancer Backend Pool.')
param adeAppVmLoadBalancerBackendPoolId string

@description('The array of properties for the ADE App Virtual Machines.')
param adeAppVirtualMachines array

@description('The ID of the ADE App Virtual Machine subnet.')
param adeAppVmSubnetId string

@description('The password of the admin user.')
@secure()
param adminPassword string

@description('The name of the admin user.')
param adminUserName string

@description('The ID of the Diagnostics Storage Account.')
param diagnosticsStorageAccountId string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The location for all resources.')
param location string

@description('The customer Id of the Log Analytics Workspace.')
param logAnalyticsWorkspaceCustomerId string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The Workspace Key of the Log Analytics Workspace.')
param logAnalyticsWorkspaceKey string

// Variables
//////////////////////////////////////////////////
var tags = {
  environment: 'production'
  function: 'adeAppVm'
  costCenter: 'it'
}

// Resource - Network Interface - ADE App Vm
//////////////////////////////////////////////////
resource adeAppVmNic 'Microsoft.Network/networkInterfaces@2020-08-01' = [for (adeAppVirtualMachine, i) in adeAppVirtualMachines: {
  name: adeAppVirtualMachine.nicName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: adeAppVmSubnetId
          }
          loadBalancerBackendAddressPools: [
            {
              id: adeAppVmLoadBalancerBackendPoolId
            }
          ]
        }
      }
    ]
  }
}]

// Resource - Network Interface - Diagnostic Settings
//////////////////////////////////////////////////
resource adeAppVmNicDiagnosticSetting 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = [for (adeAppVirtualMachine, i) in adeAppVirtualMachines: {
  scope: adeAppVmNic[i]
  name: '${adeAppVirtualMachine.nicName}-diagnostics'
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
}]

// Resource - Virtual Machine
//////////////////////////////////////////////////
resource adeAppVm 'Microsoft.Compute/virtualMachines@2020-12-01' = [for (adeAppVirtualMachine, i) in adeAppVirtualMachines: {
  name: adeAppVirtualMachine.name
  location: location
  zones: [
    adeAppVirtualMachine.availabilityZone
  ]
  tags: tags
  properties: {
    proximityPlacementGroup: {
      id: adeAppVirtualMachine.proximityPlacementGroupId
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
        name: adeAppVirtualMachine.osDiskName
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: adeAppVirtualMachine.name
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: adeAppVmNic[i].id
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
resource adeAppVmDependencyAgent 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = [for (adeAppVirtualMachine, i) in adeAppVirtualMachines: {
  name: '${adeAppVm[i].name}/DependencyAgentLinux'
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
resource adeAppVmMicrosoftMonitoringAgent 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = [for (adeAppVirtualMachine, i) in adeAppVirtualMachines: {
  name: '${adeAppVm[i].name}/OMSExtension'
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
