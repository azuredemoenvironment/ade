// Parameters
//////////////////////////////////////////////////
@description('The name of the ADE App Vmss Subnet NSG.')
param adeAppVmssSubnetNSGName string

@description('The name of the ADE App Vm Subnet NSG.')
param adeAppVmSubnetNSGName string

@description('The name of the ADE Web Vmss Subnet NSG.')
param adeWebVmssSubnetNSGName string

@description('The name of the ADE Web Vm Subnet NSG.')
param adeWebVmSubnetNSGName string

@description('The name of the Azure Bastion Subnet NSG.')
param azureBastionSubnetNSGName string

@description('The ID of the Diagnostics Storage Account.')
param diagnosticsStorageAccountId string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The name of the Management Subnet NSG.')
param managementSubnetNSGName string

@description('The public IP address of the on-premises network.')
param sourceAddressPrefix string

// Variables
//////////////////////////////////////////////////
var location = resourceGroup().location
var tags = {
  environment: 'production'
  function: 'networking'
  costCenter: 'it'
}

// Resource - Network Security Group - Azure Bastion Subnet
//////////////////////////////////////////////////
resource azureBastionSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: azureBastionSubnetNSGName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'HTTPS_Inbound'
        properties: {
          description: 'Allow HTTPS Access from Current Location'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: sourceAddressPrefix
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Gateway_Manager_Inbound'
        properties: {
          description: 'Allow Gateway Manager Access'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 200
          direction: 'Inbound'
        }
      }
      {
        name: 'SSH_RDP_Outbound'
        properties: {
          description: 'Allow SSH and RDP Outbound'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'Azure_Cloud_Outbound'
        properties: {
          description: 'Allow Azure Cloud Outbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 200
          direction: 'Outbound'
        }
      }
    ]
  }
}

// Resource - Network Security Group - Diagnostic Settings - Azure Bastion Subnet
//////////////////////////////////////////////////
resource azureBastionSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: azureBastionSubnetNSG
  name: '${azureBastionSubnetNSG.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
      }
    ]
  }
}

// Resource - Network Security Group - Management Subnet
//////////////////////////////////////////////////
resource managementSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: managementSubnetNSGName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'RDP_Inbound'
        properties: {
          description: 'Allow RDP Access from Current Location'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: sourceAddressPrefix
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

// Resource - Network Security Group - Diagnostic Settings - Management Subnet
//////////////////////////////////////////////////
resource managementSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: managementSubnetNSG
  name: '${managementSubnetNSG.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
      }
    ]
  }
}

// Resource - Network Security Group - ADE Web Vm Subnet
//////////////////////////////////////////////////
resource adeWebVmSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: adeWebVmSubnetNSGName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - ADE Web Vm Subnet
//////////////////////////////////////////////////
resource adeWebVmSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: adeWebVmSubnetNSG
  name: '${adeWebVmSubnetNSG.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
      }
    ]
  }
}

// Resource - Network Security Group - ADE App Vm Subnet
//////////////////////////////////////////////////
resource adeAppVmSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: adeAppVmSubnetNSGName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - ADE App Vm Subnet
//////////////////////////////////////////////////
resource adeAppVmSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: adeAppVmSubnetNSG
  name: '${adeAppVmSubnetNSG.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
      }
    ]
  }
}

// Resource - Network Security Group - ADE Web Vmss Subnet
//////////////////////////////////////////////////
resource adeWebVmssSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: adeWebVmssSubnetNSGName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - ADE Web Vmss Subnet
//////////////////////////////////////////////////
resource adeWebVmssSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: adeWebVmssSubnetNSG
  name: '${adeWebVmssSubnetNSG.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
      }
    ]
  }
}

// Resource - Network Security Group - ADE App Vmss Subnet
//////////////////////////////////////////////////
resource adeAppVmssSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: adeAppVmssSubnetNSGName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - ADE App Vmss Subnet
//////////////////////////////////////////////////
resource adeAppVmssSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: adeAppVmssSubnetNSG
  name: '${adeAppVmssSubnetNSG.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
      }
    ]
  }
}

// Outputs
//////////////////////////////////////////////////
output azureBastionSubnetNSGId string = azureBastionSubnetNSG.id
output managementSubnetNSGId string = managementSubnetNSG.id
output adeWebVmSubnetNSGId string = adeWebVmSubnetNSG.id
output adeAppVmSubnetNSGId string = adeAppVmSubnetNSG.id
output adeWebVmssSubnetNSGId string = adeWebVmssSubnetNSG.id
output adeAppVmssSubnetNSGId string = adeAppVmssSubnetNSG.id
output nsgConfigurations array = [
  {
    name: 'azureBastionSubnet'
    id: azureBastionSubnetNSG.id
  }
  {
    name: 'managementSubnet'
    id: managementSubnetNSG.id
  }
  {
    name: 'adeWebVmSubnet'
    id: adeWebVmSubnetNSG.id
  }
  {
    name: 'adeAppVmSubnet'
    id: adeAppVmSubnetNSG.id
  }
  {
    name: 'adeWebVmssSubnet'
    id: adeWebVmssSubnetNSG.id
  }
  {
    name: 'adeAppVmssSubnet'
    id: adeAppVmssSubnetNSG.id
  }
]
