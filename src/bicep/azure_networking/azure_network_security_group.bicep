// Parameters
//////////////////////////////////////////////////
@description('The name of the ADE App SQL Subnet NSG.')
param adeAppSqlSubnetNSGName string

@description('The name of the ADE App Vmss Subnet NSG.')
param adeAppVmssSubnetNSGName string

@description('The name of the ADE App Vm Subnet NSG.')
param adeAppVmSubnetNSGName string

@description('The name of the ADE Web Vmss Subnet NSG.')
param adeWebVmssSubnetNSGName string

@description('The name of the ADE Web Vm Subnet NSG.')
param adeWebVmSubnetNSGName string

@description('The name of the Application Gateway Subnet NSG.')
param applicationGatewaySubnetNSGName string

@description('The name of the Azure Bastion Subnet NSG.')
param azureBastionSubnetNSGName string

@description('The name of the Data Ingestor Service Subnet NSG.')
param dataIngestorServiceSubnetNSGName string

@description('The name of the Data Reporter Service Subnet NSG.')
param dataReporterServiceSubnetNSGName string

@description('The ID of the Diagnostics Storage Account.')
param diagnosticsStorageAccountId string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The name of the Event Ingestor Service Subnet NSG.')
param eventIngestorServiceSubnetNSGName string

@description('The name of the Inspector Gadget SQL Subnet NSG.')
param inspectorGadgetSqlSubnetNSGName string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The name of the Management Subnet NSG.')
param managementSubnetNSGName string

@description('The public IP address of the on-premises network.')
param sourceAddressPrefix string

@description('The name of the User Service Subnet NSG.')
param userServiceSubnetNSGName string

@description('The name of the VNET Integration Subnet NSG.')
param vnetIntegrationSubnetNSGName string

// Variables
//////////////////////////////////////////////////
var tags = {
  environment: 'production'
  function: 'networking'
  costCenter: 'it'
}

// Resource - Network Security Group - ADE App SQL Subnet
//////////////////////////////////////////////////
resource adeAppSqlSubnetNSG 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: adeAppSqlSubnetNSGName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - ADE App SQL Subnet
//////////////////////////////////////////////////
resource adeAppSqlSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: adeAppSqlSubnetNSG
  name: '${adeAppSqlSubnetNSG.name}-diagnostics'
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
resource adeAppVmssSubnetNSG 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
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
resource adeAppVmSubnetNSG 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
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
resource adeWebVmssSubnetNSG 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
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
resource adeWebVmSubnetNSG 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
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
resource applicationGatewaySubnetNSG 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: applicationGatewaySubnetNSGName
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
resource applicationGatewaySubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: applicationGatewaySubnetNSG
  name: '${applicationGatewaySubnetNSG.name}-diagnostics'
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
resource azureBastionSubnetNSG 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
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
resource dataIngestorServiceSubnetNSG 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: dataIngestorServiceSubnetNSGName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - Data Ingestor Service Subnet
//////////////////////////////////////////////////
resource dataIngestorServiceSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: dataIngestorServiceSubnetNSG
  name: '${dataIngestorServiceSubnetNSG.name}-diagnostics'
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
resource dataReporterServiceSubnetNSG 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: dataReporterServiceSubnetNSGName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - Data Reporter Service Subnet
//////////////////////////////////////////////////
resource dataReporterServiceSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: dataReporterServiceSubnetNSG
  name: '${dataReporterServiceSubnetNSG.name}-diagnostics'
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
resource eventIngestorServiceSubnetNSG 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: eventIngestorServiceSubnetNSGName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - Event Ingestor Service Subnet
//////////////////////////////////////////////////
resource eventIngestorServiceSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: eventIngestorServiceSubnetNSG
  name: '${eventIngestorServiceSubnetNSG.name}-diagnostics'
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
resource inspectorGadgetSqlSubnetNSG 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: inspectorGadgetSqlSubnetNSGName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - Inspector Gadget SQL Subnet
//////////////////////////////////////////////////
resource inspectorGadgetSqlSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: inspectorGadgetSqlSubnetNSG
  name: '${inspectorGadgetSqlSubnetNSG.name}-diagnostics'
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
resource managementSubnetNSG 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
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
resource userServiceSubnetNSG 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: userServiceSubnetNSGName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - Inspector Gadget SQL Subnet
//////////////////////////////////////////////////
resource userServiceSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: userServiceSubnetNSG
  name: '${userServiceSubnetNSG.name}-diagnostics'
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
resource vnetIntegrationSubnetNSG 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: vnetIntegrationSubnetNSGName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - VNET Integration Subnet
//////////////////////////////////////////////////
resource vnetIntegrationSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: vnetIntegrationSubnetNSG
  name: '${vnetIntegrationSubnetNSG.name}-diagnostics'
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
output adeAppSqlSubnetNSGId string = adeAppSqlSubnetNSG.id
output adeAppVmssSubnetNSGId string = adeAppVmssSubnetNSG.id
output adeAppVmSubnetNSGId string = adeAppVmSubnetNSG.id
output adeWebVmssSubnetNSGId string = adeWebVmssSubnetNSG.id
output adeWebVmSubnetNSGId string = adeWebVmSubnetNSG.id
output applicationGatewaySubnetNSGId string = applicationGatewaySubnetNSG.id
output azureBastionSubnetNSGId string = azureBastionSubnetNSG.id
output dataIngestorServiceSubnetNSGId string = dataIngestorServiceSubnetNSG.id
output dataReporterServiceSubnetNSGId string = dataReporterServiceSubnetNSG.id
output eventIngestorServiceSubnetNSGId string = eventIngestorServiceSubnetNSG.id
output inspectorGadgetSqlSubnetNSGId string = inspectorGadgetSqlSubnetNSG.id
output managementSubnetNSGId string = managementSubnetNSG.id
output nsgConfigurations array = [  
  {
    name: 'adeAppSqlSubnet'
    id: adeAppSqlSubnetNSG.id
  }
  {
    name: 'adeAppVmssSubnet'
    id: adeAppVmssSubnetNSG.id
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
    name: 'adeWebVmSubnet'
    id: adeWebVmSubnetNSG.id
  }
  {
    name: 'applicationGatewaySubnet'
    id: applicationGatewaySubnetNSG.id
  }
  {
    name: 'azureBastionSubnet'
    id: azureBastionSubnetNSG.id
  }
  {
    name: 'dataIngestorServiceSubnet'
    id: dataIngestorServiceSubnetNSG.id
  }
  {
    name: 'dataReporterServiceSubnet'
    id: dataReporterServiceSubnetNSG.id
  }
  {
    name: 'eventIngestorServiceSubnet'
    id: eventIngestorServiceSubnetNSG.id
  }
  {
    name: 'inspectorGadgetSqlSubnet'
    id: inspectorGadgetSqlSubnetNSG.id
  }
  {
    name: 'managementSubnet'
    id: managementSubnetNSG.id
  }
  {
    name: 'userServiceSubnet'
    id: userServiceSubnetNSG.id
  }
  {
    name: 'vnetIntegrationSubnet'
    id: vnetIntegrationSubnetNSG.id
  }
]
output userServiceSubnetNSGId string = userServiceSubnetNSG.id
output vnetIntegrationSubnetNSGId string = vnetIntegrationSubnetNSG.id
