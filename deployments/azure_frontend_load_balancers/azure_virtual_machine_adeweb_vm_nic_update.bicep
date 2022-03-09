// Parameters
//////////////////////////////////////////////////
@description('The ID of the ADE App Api Gateway Backend Pool.')
param adeAppApiGatewayBackendPoolId string

@description('The ID of the ADE App Api Gateway Virtual Machine Backend Pool.')
param adeAppApiGatewayVmBackendPoolId string

@description('The array of properties for the ADE Web Virtual Machines.')
param adeWebVirtualMachines array

@description('The ID of the ADE App Frontend Backend Pool.')
param adeAppFrontendBackendPoolId string

@description('The ID of the ADE App Frontend Virtual Machine Backend Pool.')
param adeAppFrontendVmBackendPoolId string

@description('The ID of the ADE Web Virtual Machine subnet.')
param adeWebVmSubnetId string

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
