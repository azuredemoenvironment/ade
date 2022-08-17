// Parameters
//////////////////////////////////////////////////
@description('The name of the ADE App SQL Subnet Nsg.')
param adeAppSqlSubnetNsgName string

@description('The name of the ADE App Vmss Subnet Nsg.')
param adeAppVmssSubnetNsgName string

@description('The name of the ADE App Vm Subnet Nsg.')
param adeAppVmSubnetNsgName string

@description('The name of the ADE Web Vmss Subnet Nsg.')
param adeWebVmssSubnetNsgName string

@description('The name of the ADE Web Vm Subnet Nsg.')
param adeWebVmSubnetNsgName string

@description('The name of the Application Gateway Subnet Nsg.')
param applicationGatewaySubnetNsgName string

@description('The name of the Azure Bastion Subnet Nsg.')
param azureBastionSubnetNsgName string

@description('The name of the Data Ingestor Service Subnet Nsg.')
param dataIngestorServiceSubnetNsgName string

@description('The name of the Data Reporter Service Subnet Nsg.')
param dataReporterServiceSubnetNsgName string

@description('The ID of the Diagnostics Storage Account.')
param diagnosticsStorageAccountId string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The name of the Event Ingestor Service Subnet Nsg.')
param eventIngestorServiceSubnetNsgName string

@description('The name of the Inspector Gadget SQL Subnet Nsg.')
param inspectorGadgetSqlSubnetNsgName string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The name of the Management Subnet Nsg.')
param managementSubnetNsgName string

@description('The public IP address of the on-premises network.')
param sourceAddressPrefix string

@description('The name of the User Service Subnet Nsg.')
param userServiceSubnetNsgName string

@description('The name of the VNET Integration Subnet Nsg.')
param vnetIntegrationSubnetNsgName string

// Variables
//////////////////////////////////////////////////
var tags = {
  environment: 'production'
  function: 'networking'
  costCenter: 'it'
}

// Resource - Network Security Group - ADE App SQL Subnet
//////////////////////////////////////////////////
resource adeAppSqlSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: adeAppSqlSubnetNsgName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - ADE App SQL Subnet
//////////////////////////////////////////////////
resource adeAppSqlSubnetNsgDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: adeAppSqlSubnetNsg
  name: '${adeAppSqlSubnetNsg.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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
resource adeAppVmssSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: adeAppVmssSubnetNsgName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - ADE App Vmss Subnet
//////////////////////////////////////////////////
resource adeAppVmssSubnetNsgDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: adeAppVmssSubnetNsg
  name: '${adeAppVmssSubnetNsg.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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
resource adeAppVmSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: adeAppVmSubnetNsgName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - ADE App Vm Subnet
//////////////////////////////////////////////////
resource adeAppVmSubnetNsgDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: adeAppVmSubnetNsg
  name: '${adeAppVmSubnetNsg.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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
resource adeWebVmssSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: adeWebVmssSubnetNsgName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - ADE Web Vmss Subnet
//////////////////////////////////////////////////
resource adeWebVmssSubnetNsgDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: adeWebVmssSubnetNsg
  name: '${adeWebVmssSubnetNsg.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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
resource adeWebVmSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: adeWebVmSubnetNsgName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - ADE Web Vm Subnet
//////////////////////////////////////////////////
resource adeWebVmSubnetNsgDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: adeWebVmSubnetNsg
  name: '${adeWebVmSubnetNsg.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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

// Resource - Network Security Group - Application Gateway Subnet
//////////////////////////////////////////////////
resource applicationGatewaySubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: applicationGatewaySubnetNsgName
  location: location
  tags: tags
  properties: {
    securityRules: [      
      {
        name: 'Gateway_Manager_Inbound'
        properties: {
          description: 'Allow Gateway Manager Access'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '65200-65535'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'HTTP_Inbound'
        properties: {
          description: 'Allow HTTP Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 200
          direction: 'Inbound'
        }
      }
      {
        name: 'HTTPS_Inbound'
        properties: {
          description: 'Allow HTTPS Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
        }
      }
    ]
  }
}

// Resource - Network Security Group - Diagnostic Settings - Application Gateway Subnet
//////////////////////////////////////////////////
resource applicationGatewaySubnetNsgDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: applicationGatewaySubnetNsg
  name: '${applicationGatewaySubnetNsg.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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

// Resource - Network Security Group - Azure Bastion Subnet
//////////////////////////////////////////////////
resource azureBastionSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: azureBastionSubnetNsgName
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
resource azureBastionSubnetNsgDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: azureBastionSubnetNsg
  name: '${azureBastionSubnetNsg.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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

// Resource - Network Security Group - Data Ingestor Service Subnet
//////////////////////////////////////////////////
resource dataIngestorServiceSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: dataIngestorServiceSubnetNsgName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - Data Ingestor Service Subnet
//////////////////////////////////////////////////
resource dataIngestorServiceSubnetNsgDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: dataIngestorServiceSubnetNsg
  name: '${dataIngestorServiceSubnetNsg.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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

// Resource - Network Security Group - Data Reporter Service Subnet
//////////////////////////////////////////////////
resource dataReporterServiceSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: dataReporterServiceSubnetNsgName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - Data Reporter Service Subnet
//////////////////////////////////////////////////
resource dataReporterServiceSubnetNsgDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: dataReporterServiceSubnetNsg
  name: '${dataReporterServiceSubnetNsg.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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

// Resource - Network Security Group - Event Ingestor Service Subnet
//////////////////////////////////////////////////
resource eventIngestorServiceSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: eventIngestorServiceSubnetNsgName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - Event Ingestor Service Subnet
//////////////////////////////////////////////////
resource eventIngestorServiceSubnetNsgDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: eventIngestorServiceSubnetNsg
  name: '${eventIngestorServiceSubnetNsg.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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

// Resource - Network Security Group - Inspector Gadget SQL Subnet
//////////////////////////////////////////////////
resource inspectorGadgetSqlSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: inspectorGadgetSqlSubnetNsgName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - Inspector Gadget SQL Subnet
//////////////////////////////////////////////////
resource inspectorGadgetSqlSubnetNsgDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: inspectorGadgetSqlSubnetNsg
  name: '${inspectorGadgetSqlSubnetNsg.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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
resource managementSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: managementSubnetNsgName
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
resource managementSubnetNsgDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: managementSubnetNsg
  name: '${managementSubnetNsg.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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

// Resource - Network Security Group - Inspector Gadget SQL Subnet
//////////////////////////////////////////////////
resource userServiceSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: userServiceSubnetNsgName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - Inspector Gadget SQL Subnet
//////////////////////////////////////////////////
resource userServiceSubnetNsgDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: userServiceSubnetNsg
  name: '${userServiceSubnetNsg.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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

// Resource - Network Security Group - VNET Integration Subnet
//////////////////////////////////////////////////
resource vnetIntegrationSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: vnetIntegrationSubnetNsgName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - VNET Integration Subnet
//////////////////////////////////////////////////
resource vnetIntegrationSubnetNsgDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: vnetIntegrationSubnetNsg
  name: '${vnetIntegrationSubnetNsg.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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
output adeAppSqlSubnetNsgId string = adeAppSqlSubnetNsg.id
output adeAppVmssSubnetNsgId string = adeAppVmssSubnetNsg.id
output adeAppVmSubnetNsgId string = adeAppVmSubnetNsg.id
output adeWebVmssSubnetNsgId string = adeWebVmssSubnetNsg.id
output adeWebVmSubnetNsgId string = adeWebVmSubnetNsg.id
output applicationGatewaySubnetNsgId string = applicationGatewaySubnetNsg.id
output azureBastionSubnetNsgId string = azureBastionSubnetNsg.id
output dataIngestorServiceSubnetNsgId string = dataIngestorServiceSubnetNsg.id
output dataReporterServiceSubnetNsgId string = dataReporterServiceSubnetNsg.id
output eventIngestorServiceSubnetNsgId string = eventIngestorServiceSubnetNsg.id
output inspectorGadgetSqlSubnetNsgId string = inspectorGadgetSqlSubnetNsg.id
output managementSubnetNsgId string = managementSubnetNsg.id
output nsgConfigurations array = [  
  {
    name: 'adeAppSqlSubnet'
    id: adeAppSqlSubnetNsg.id
  }
  {
    name: 'adeAppVmssSubnet'
    id: adeAppVmssSubnetNsg.id
  }
  {
    name: 'adeAppVmSubnet'
    id: adeAppVmSubnetNsg.id
  }
  {
    name: 'adeWebVmssSubnet'
    id: adeWebVmssSubnetNsg.id
  }
  {
    name: 'adeWebVmSubnet'
    id: adeWebVmSubnetNsg.id
  }
  {
    name: 'applicationGatewaySubnet'
    id: applicationGatewaySubnetNsg.id
  }
  {
    name: 'azureBastionSubnet'
    id: azureBastionSubnetNsg.id
  }
  {
    name: 'dataIngestorServiceSubnet'
    id: dataIngestorServiceSubnetNsg.id
  }
  {
    name: 'dataReporterServiceSubnet'
    id: dataReporterServiceSubnetNsg.id
  }
  {
    name: 'eventIngestorServiceSubnet'
    id: eventIngestorServiceSubnetNsg.id
  }
  {
    name: 'inspectorGadgetSqlSubnet'
    id: inspectorGadgetSqlSubnetNsg.id
  }
  {
    name: 'managementSubnet'
    id: managementSubnetNsg.id
  }
  {
    name: 'userServiceSubnet'
    id: userServiceSubnetNsg.id
  }
  {
    name: 'vnetIntegrationSubnet'
    id: vnetIntegrationSubnetNsg.id
  }
]
output userServiceSubnetNsgId string = userServiceSubnetNsg.id
output vnetIntegrationSubnetNsgId string = vnetIntegrationSubnetNsg.id
