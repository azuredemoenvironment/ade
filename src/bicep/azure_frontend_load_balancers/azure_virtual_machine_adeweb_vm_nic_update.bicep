// Parameters
//////////////////////////////////////////////////
@description('The ID of the  App Api Gateway Backend Pool.')
param adeAppApiGatewayBackendPoolId string

@description('The ID of the  App Api Gateway Virtual Machine Backend Pool.')
param adeAppApiGatewayVmBackendPoolId string

@description('The array of properties for the  Web Virtual Machines.')
param adeWebVirtualMachines array

@description('The ID of the  App Frontend Backend Pool.')
param adeAppFrontendBackendPoolId string

@description('The ID of the  App Frontend Virtual Machine Backend Pool.')
param adeAppFrontendVmBackendPoolId string

@description('The ID of the  Web Virtual Machine subnet.')
param adeWebVmSubnetId string

@description('The ID of the Diagnostics Storage Account.')
param diagnosticsStorageAccountId string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

// Variables
//////////////////////////////////////////////////
var tags = {
  environment: 'production'
  function: 'adeWebVm'
  costCenter: 'it'
}

// Resource - Network Interface -  Web Vm
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
          applicationGatewayBackendAddressPools: [
            {
              id: adeAppApiGatewayBackendPoolId
            }
            {
              id: adeAppApiGatewayVmBackendPoolId
            }
            {
              id: adeAppFrontendBackendPoolId
            }
            {
              id: adeAppFrontendVmBackendPoolId
            }
          ]
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
