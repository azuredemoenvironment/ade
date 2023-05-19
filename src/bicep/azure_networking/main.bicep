// Parameters
//////////////////////////////////////////////////
@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('The application global environment (workload, environment, location).')
param appGlobalEnvironment string

@description('The current date.')
param currentDate string = utcNow('yyyy-MM-dd')

@description('Deploy Azure Firewall if value is set to true.')
param deployFirewall bool = true

@description('The name of the Dns Zone Resource Group.')
param dnsZoneResourceGroupName string

@description('The version of the Key Vault Secret.')
param keyVaultSecretVersion string = ''

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of the Management Resource Group.')
param managementResourceGroupName string

@description('The name of the owner of the deployment.')
param ownerName string

@description('The value for Root Domain Name.')
param rootDomainName string

@description('The name of the Security Resource Group.')
param securityResourceGroupName string

@description('The public IP address of the on-premises network.')
param sourceAddressPrefix string

@description('The name of the SSL Certificate.')
param sslCertificateName string

// Variables
//////////////////////////////////////////////////
var tags = {
  deploymentDate: currentDate
  owner: ownerName
}

// Variables - Storage Account
//////////////////////////////////////////////////
var nsgFlowLogsStorageAccountName = replace('sa-nsgflow-${uniqueString(subscription().subscriptionId)}', '-', '')
var nsgFlowLogsStorageAccountProperties = {
  accessTier: 'Hot'
  httpsOnly: true
  kind: 'StorageV2'
  sku: 'Standard_GRS'
}

// Variables - Nat Gateway
//////////////////////////////////////////////////
var natGatewayName = 'ngw-${appEnvironment}'
var natGatewayProperties = {
  skuName: 'Standard'
  idleTimeoutInMinutes: 4
}
var publicIpPrefixName = 'pipp-${appEnvironment}-ngw'
var publicIpPrefixProperties = {
  skuName: 'Standard'
  prefixLength: 31
  publicIPAddressVersion: 'IPv4'
}

// Variables - Network Security Group
//////////////////////////////////////////////////
var networkSecurityGroups = [
  {
    name: 'nsg-${appEnvironment}-applicationGateway'
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
  {
    name: 'nsg-${appEnvironment}-bastion'
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
  {
    name: 'nsg-${appEnvironment}-adeWeb-vm'
    properties: {}
  }
  {
    name: 'nsg-${appEnvironment}-adeApp-vm'
    properties: {}
  }
  {
    name: 'nsg-${appEnvironment}-adeWeb-vmss'
    properties: {}
  }
  {
    name: 'nsg-${appEnvironment}-adeApp-vmss'
    properties: {}
  }
  {
    name: 'nsg-${appEnvironment}-userService'
    properties: {}
  }
  {
    name: 'nsg-${appEnvironment}-dataIngestorService'
    properties: {}
  }
  {
    name: 'nsg-${appEnvironment}-dataReporterService'
    properties: {}
  }
  {
    name: 'nsg-${appEnvironment}-eventIngestorService'
    properties: {}
  }
  {
    name: 'nsg-${appEnvironment}-adeAppSql'
    properties: {}
  }
  {
    name: 'nsg-${appEnvironment}-inspectorGadgetSql'
    properties: {}
  }
  {
    name: 'nsg-${appEnvironment}-vnetIntegration'
    properties: {}
  }
]

// Variables - Route Table
//////////////////////////////////////////////////
var routeTableName = 'rt-${appEnvironment}'
var routes = [
  {
    name: 'toInternet'
    addressPrefix: '0.0.0.0/0'
    nextHopType: 'VirtualAppliance'
    nextHopIpAddress: firewallPrivateIpAddress
  }
]

// Variables - Virtual Network
//////////////////////////////////////////////////
var applicationGatewaySubnetName = 'snet-${appEnvironment}-applicationGateway'
var hubVirtualNetworkName = 'vnet-${appEnvironment}-hub'
var hubVirtualNetworkPrefix = '10.101.0.0/16'
var hubVirtualNetworkSubnets = [  
  {
    name: 'AzureFirewallSubnet'
    properties: {
      addressPrefix: '10.101.1.0/24'
    }
  }
  {
    name: applicationGatewaySubnetName
    properties: {
      addressPrefix: '10.101.11.0/24'
      networkSecurityGroup: {
        id: networkSecurityGroupModule.outputs.networkSecurityGroupProperties[0].resourceId
      }
      serviceEndpoints: [
        {
          service: 'Microsoft.Web'
        }
      ]
    }
  }
  {
    name: 'AzureBastionSubnet'
    properties: {
      addressPrefix: '10.101.21.0/24'
      networkSecurityGroup: {
        id: networkSecurityGroupModule.outputs.networkSecurityGroupProperties[1].resourceId
      }
    }
  }
  {
    name: 'GatewaySubnet'
    properties: {
      addressPrefix: '10.101.255.0/24'
    }
  }
]
var spokeVirtualNetworkName = 'vnet-${appEnvironment}-spoke'
var spokeVirtualNetworkPrefix = '10.102.0.0/16'
var spokeVirtualNetworkSubnets = [  
  {
    name: 'snet-${appEnvironment}-adeWeb-vm'
    properties: {
      addressPrefix: '10.102.1.0/24'
      natGateway: {
        id: natGatewayModule.outputs.natGatewayId
      }
      networkSecurityGroup: {
        id: networkSecurityGroupModule.outputs.networkSecurityGroupProperties[2].resourceId
      }
      serviceEndpoints: [
        {
          service: 'Microsoft.Sql'
        }
      ]
    }
  }
  {
    name: 'snet-${appEnvironment}-adeApp-vm'
    properties: {
      addressPrefix: '10.102.2.0/24'
      natGateway: {
        id: natGatewayModule.outputs.natGatewayId
      }
      networkSecurityGroup: {
        id: networkSecurityGroupModule.outputs.networkSecurityGroupProperties[3].resourceId
      }
      serviceEndpoints: [
        {
          service: 'Microsoft.Sql'
        }
      ]
    }
  }
  {
    name: 'snet-${appEnvironment}-adeWeb-vmss'
    properties: {
      addressPrefix: '10.102.11.0/24'
      natGateway: {
        id: natGatewayModule.outputs.natGatewayId
      }
      networkSecurityGroup: {
        id: networkSecurityGroupModule.outputs.networkSecurityGroupProperties[4].resourceId
      }
      serviceEndpoints: [
        {
          service: 'Microsoft.Sql'
        }
      ]
    }
  }
  {
    name: 'snet-${appEnvironment}-adeApp-vmss'
    properties: {
      addressPrefix: '10.102.12.0/24'
      natGateway: {
        id: natGatewayModule.outputs.natGatewayId
      }
      networkSecurityGroup: {
        id: networkSecurityGroupModule.outputs.networkSecurityGroupProperties[5].resourceId
      }
      serviceEndpoints: [
        {
          service: 'Microsoft.Sql'
        }
      ]
    }
  }
  {
    name: 'snet-${appEnvironment}-adeApp-aks'
    properties: {
      addressPrefix: '10.102.100.0/23'
      serviceEndpoints: [
        {
          service: 'Microsoft.ContainerRegistry'
        }
      ]
    }
  }
  {
    name: 'snet-${appEnvironment}-userService'
    properties: {
      addressPrefix: '10.102.151.0/24'
      networkSecurityGroup: {
        id: networkSecurityGroupModule.outputs.networkSecurityGroupProperties[6].resourceId
      }
      privateEndpointNetworkPolicies: 'Enabled'
    }
  }
  {
    name: 'snet-${appEnvironment}-dataIngestorService'
    properties: {
      addressPrefix: '10.102.152.0/24'
      networkSecurityGroup: {
        id: networkSecurityGroupModule.outputs.networkSecurityGroupProperties[7].resourceId
      }
      privateEndpointNetworkPolicies: 'Enabled'
    }
  }
  {
    name: 'snet-${appEnvironment}-dataReporterService'
    properties: {
      addressPrefix: '10.102.153.0/24'
      networkSecurityGroup: {
        id: networkSecurityGroupModule.outputs.networkSecurityGroupProperties[8].resourceId
      }
      privateEndpointNetworkPolicies: 'Enabled'
    }
  }
  {
    name: 'snet-${appEnvironment}-eventIngestorService'
    properties: {
      addressPrefix: '10.102.154.0/24'
      networkSecurityGroup: {
        id: networkSecurityGroupModule.outputs.networkSecurityGroupProperties[9].resourceId
      }
      privateEndpointNetworkPolicies: 'Enabled'
    }
  }
  {
    name: 'snet-${appEnvironment}-adeAppSql'
    properties: {
      addressPrefix: '10.102.160.0/24'
      networkSecurityGroup: {
        id: networkSecurityGroupModule.outputs.networkSecurityGroupProperties[10].resourceId
      }
      privateEndpointNetworkPolicies: 'Enabled'
    }
  }
  {
    name: 'snet-${appEnvironment}-inspectorGadgetSql'
    properties: {
      addressPrefix: '10.102.161.0/24'
      networkSecurityGroup: {
        id: networkSecurityGroupModule.outputs.networkSecurityGroupProperties[11].resourceId
      }
      privateEndpointNetworkPolicies: 'Enabled'
    }
  }
  {
    name: 'snet-${appEnvironment}-vnetIntegration'
    properties: {
      addressPrefix: '10.102.201.0/24'
      delegations: [
        {
          name: 'appServicePlanDelegation'
          properties: {
            serviceName: 'Microsoft.Web/serverFarms'
          }
        }
      ]
      networkSecurityGroup: {
        id: networkSecurityGroupModule.outputs.networkSecurityGroupProperties[12].resourceId
      }
      privateEndpointNetworkPolicies: 'Enabled'
    }
  }
]

// Variables - Firewall
//////////////////////////////////////////////////
var firewallName = 'fw-${appEnvironment}'
var firewallPublicIpAddressName = 'pip-${appEnvironment}-fw'
var firewallPublicIpAddressProperties = {
  name: firewallPublicIpAddressName
  publicIPAllocationMethod: 'Static'
  publicIPAddressVersion: 'IPv4'
  sku: 'Standard'
}
var firewallPrivateIpAddress = '10.101.0.4'
var firewallProperties = {
  name: firewallName
}

// Variables - Bastion
//////////////////////////////////////////////////
var bastionName = 'bastion-${appEnvironment}'
var bastionPublicIpAddressName = 'pip-${appEnvironment}-bastion'
var bastionPublicIpAddressProperties = {
  name: bastionPublicIpAddressName
  publicIPAllocationMethod: 'Static'
  publicIPAddressVersion: 'IPv4'
  sku: 'Standard'
}

// Variables - Application Gateway
//////////////////////////////////////////////////
var apiGatewayVmHostName = 'apigateway-vm.${rootDomainName}'
var apiGatewayVmssHostName = 'apigateway-vmss.${rootDomainName}'
var applicationGatewayName = 'appgw-${appEnvironment}'
var applicationGatewayPublicIpAddressName = 'pip-${appEnvironment}-appgw'
var frontendVmHostName = 'frontEnd-vm.${rootDomainName}'
var frontendVmssHostName = 'frontEnd-vmss.${rootDomainName}'
var sslCertificateDataPassword = ''
var applicationGatewayPublicIpAddressProperties = {
  name: applicationGatewayPublicIpAddressName
  publicIPAllocationMethod: 'Static'
  publicIPAddressVersion: 'IPv4'
  sku: 'Standard'
}
var applicationGatewayProperties = {
  name: applicationGatewayName
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${applicationGatewayManagedIdentity.id}': {}
    }
  }
  properties: {
    backendAddressPools: backendAddressPools
    backendHttpSettingsCollection: backendHttpSettingsCollection
    enableHttp2: false
    frontendPorts: frontendPorts
    gatewayIPConfigurations: gatewayIPConfigurations
    httpListeners: httpListeners
    probes: probes
    redirectConfigurations: redirectConfigurations
    requestRoutingRules: requestRoutingRules
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: 1
    }
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Prevention'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.1'
    }
  }
}
var backendAddressPools = [
  {
    name: 'backendPool-apigateway-vm'
    properties: {}
  }
  {
    name: 'backendPool-apigateway-vmss'
    properties: {}
  }
  {
    name: 'backendPool-frontend-vm'
    properties: {}
  }
  {
    name: 'backendPool-frontend-vmss'
    properties: {}
  }
]
var backendHttpSettingsCollection = [
  {
    name: 'backendsetting-apigateway-vm'
    properties: {
      port: 8080
      protocol: 'Http'
      cookieBasedAffinity: 'Disabled'
      requestTimeout: 30
      pickHostNameFromBackendAddress: true
      probe: {
        id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'probe-apigateway-vm')
      }
    }
  }
  {
    name: 'backendsetting-apigateway-vmss'
    properties: {
      port: 8080
      protocol: 'Http'
      cookieBasedAffinity: 'Disabled'
      requestTimeout: 30
      pickHostNameFromBackendAddress: true
      probe: {
        id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'probe-apigateway-vmss')
      }
    }
  }
  {
    name: 'backendsetting-frontend-vm'
    properties: {
      port: 80
      protocol: 'Http'
      cookieBasedAffinity: 'Disabled'
      requestTimeout: 30
      pickHostNameFromBackendAddress: true
      probe: {
        id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'probe-frontend-vm')
      }
    }
  }
  {
    name: 'backendsetting-frontend-vmss'
    properties: {
      port: 80
      protocol: 'Http'
      cookieBasedAffinity: 'Disabled'
      requestTimeout: 30
      pickHostNameFromBackendAddress: true
      probe: {
        id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'probe-frontend-vmss')
      }
    }
  }
]
var frontendPorts = [
  {
    name: 'port_80'
    properties: {
      port: 80
    }
  }
  {
    name: 'port_443'
    properties: {
      port: 443
    }
  }
]
var gatewayIPConfigurations = [
  {
    name: 'appGatewayIPConfig'
    properties: {
      subnet: {
        id: virtualNetworkModule.outputs.applicationGatewaySubnetId
      }
    }
  }
]
var httpListeners = [
  {
    name: 'listener-http-apigateway-vm'
    properties: {
      frontendIPConfiguration: {
        id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontendIpConfiguration')
      }
      frontendPort: {
        id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_80')
      }
      protocol: 'Http'
      hostName: apiGatewayVmHostName
      requireServerNameIndication: false
    }
  }
  {
    name: 'listener-https-apigateway-vm'
    properties: {
      frontendIPConfiguration: {
        id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontendIpConfiguration')
      }
      frontendPort: {
        id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_443')
      }
      protocol: 'Https'
      sslCertificate: {
        id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGatewayName, sslCertificateName)
      }
      hostName: apiGatewayVmHostName
      requireServerNameIndication: false
    }
  }
  {
    name: 'listener-http-apigateway-vmss'
    properties: {
      frontendIPConfiguration: {
        id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontendIpConfiguration')
      }
      frontendPort: {
        id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_80')
      }
      protocol: 'Http'
      hostName: apiGatewayVmssHostName
      requireServerNameIndication: false
    }
  }
  {
    name: 'listener-https-apigateway-vmss'
    properties: {
      frontendIPConfiguration: {
        id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontendIpConfiguration')
      }
      frontendPort: {
        id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_443')
      }
      protocol: 'Https'
      sslCertificate: {
        id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGatewayName, sslCertificateName)
      }
      hostName: apiGatewayVmssHostName
      requireServerNameIndication: false
    }
  }
  {
    name: 'listener-http-frontend-vm'
    properties: {
      frontendIPConfiguration: {
        id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontendIpConfiguration')
      }
      frontendPort: {
        id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_80')
      }
      protocol: 'Http'
      hostName: frontendVmHostName
      requireServerNameIndication: false
    }
  }
  {
    name: 'listener-https-frontend-vm'
    properties: {
      frontendIPConfiguration: {
        id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontendIpConfiguration')
      }
      frontendPort: {
        id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_443')
      }
      protocol: 'Https'
      sslCertificate: {
        id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGatewayName, sslCertificateName)
      }
      hostName: frontendVmHostName
      requireServerNameIndication: false
    }
  }
  {
    name: 'listener-http-frontend-vmss'
    properties: {
      frontendIPConfiguration: {
        id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontendIpConfiguration')
      }
      frontendPort: {
        id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_80')
      }
      protocol: 'Http'
      hostName: frontendVmssHostName
      requireServerNameIndication: false
    }
  }
  {
    name: 'listener-https-frontend-vmss'
    properties: {
      frontendIPConfiguration: {
        id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontendIpConfiguration')
      }
      frontendPort: {
        id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_443')
      }
      protocol: 'Https'
      sslCertificate: {
        id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGatewayName, sslCertificateName)
      }
      hostName: frontendVmssHostName
      requireServerNameIndication: false
    }
  }
]
var probes = [
  {
    name: 'probe-apigateway-vm'
    properties: {
      interval: 30
      path: '/swagger'
      protocol: 'Http'
      timeout: 30
      unhealthyThreshold: 3
      pickHostNameFromBackendHttpSettings: true
    }
  }
  {
    name: 'probe-apigateway-vmss'
    properties: {
      interval: 30
      path: '/swagger'
      protocol: 'Http'
      timeout: 30
      unhealthyThreshold: 3
      pickHostNameFromBackendHttpSettings: true
    }
  }
  {
    name: 'probe-frontend-vm'
    properties: {
      interval: 30
      path: '/'
      protocol: 'Http'
      timeout: 30
      unhealthyThreshold: 3
      pickHostNameFromBackendHttpSettings: true
    }
  }
  {
    name: 'probe-frontend-vmss'
    properties: {
      interval: 30
      path: '/'
      protocol: 'Http'
      timeout: 30
      unhealthyThreshold: 3
      pickHostNameFromBackendHttpSettings: true
    }
  }
]
var redirectConfigurations = [
  {
    name: 'redirectionconfig-apigateway-vm'
    properties: {
      redirectType: 'Permanent'
      targetListener: {
        id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'listener-https-apigateway-vm')
      }
    }
  }
  {
    name: 'redirectionconfig-apigateway-vmss'
    properties: {
      redirectType: 'Permanent'
      targetListener: {
        id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'listener-https-apigateway-vmss')
      }
    }
  }
  {
    name: 'redirectionconfig-frontend-vm'
    properties: {
      redirectType: 'Permanent'
      targetListener: {
        id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'listener-https-frontend-vm')
      }
    }
  }
  {
    name: 'redirectionconfig-frontend-vmss'
    properties: {
      redirectType: 'Permanent'
      targetListener: {
        id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'listener-https-frontend-vmss')
      }
    }
  }
]
var requestRoutingRules = [
  {
    name: 'routingrule-apigateway-vm'
    properties: {
      ruleType: 'Basic'
      priority: 10
      httpListener: {
        id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'listener-https-apigateway-vm')
      }
      backendAddressPool: {
        id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'backendPool-apigateway-vm')
      }
      backendHttpSettings: {
        id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'backendsetting-apigateway-vm')
      }
    }
  }
  {
    name: 'routingrule-redirection-apigateway-vm'
    properties: {
      ruleType: 'Basic'
      priority: 20
      httpListener: {
        id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'listener-http-apigateway-vm')
      }
      redirectConfiguration: {
        id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, 'redirectionconfig-apigateway-vm')
      }
    }
  }
  {
    name: 'routingrule-apigateway-vmss'
    properties: {
      ruleType: 'Basic'
      priority: 30
      httpListener: {
        id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'listener-https-apigateway-vmss')
      }
      backendAddressPool: {
        id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'backendPool-apigateway-vmss')
      }
      backendHttpSettings: {
        id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'backendsetting-apigateway-vmss')
      }
    }
  }
  {
    name: 'routingrule-redirection-apigateway-vmss'
    properties: {
      ruleType: 'Basic'
      priority: 40
      httpListener: {
        id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'listener-http-apigateway-vmss')
      }
      redirectConfiguration: {
        id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, 'redirectionconfig-apigateway-vmss')
      }
    }
  }
  {
    name: 'routingrule-frontend-vm'
    properties: {
      ruleType: 'Basic'
      priority: 50
      httpListener: {
        id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'listener-https-frontend-vm')
      }
      backendAddressPool: {
        id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'backendPool-frontend-vm')
      }
      backendHttpSettings: {
        id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'backendsetting-frontend-vm')
      }
    }
  }
  {
    name: 'routingrule-redirection-frontend-vm'
    properties: {
      ruleType: 'Basic'
      priority: 60
      httpListener: {
        id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'listener-http-frontend-vm')
      }
      redirectConfiguration: {
        id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, 'redirectionconfig-frontend-vm')
      }
    }
  }
  {
    name: 'routingrule-frontend-vmss'
    properties: {
      ruleType: 'Basic'
      priority: 70
      httpListener: {
        id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'listener-https-frontend-vmss')
      }
      backendAddressPool: {
        id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'backendPool-frontend-vmss')
      }
      backendHttpSettings: {
        id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'backendsetting-frontend-vmss')
      }
    }
  }
  {
    name: 'routingrule-redirection-frontend-vmss'
    properties: {
      ruleType: 'Basic'
      priority: 80
      httpListener: {
        id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'listener-http-frontend-vmss')
      }
      redirectConfiguration: {
        id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, 'redirectionconfig-frontend-vmss')
      }
    }
  }
]

// Variables - Front Door
//////////////////////////////////////////////////
var frontDoorProfileProperties = {
  name: 'afd-${appGlobalEnvironment}'
  skuName: 'Standard_AzureFrontDoor'
}
var frontDoorEndpointProperties = {
  name: 'fde-${appGlobalEnvironment}'
  enabledState: 'Enabled'
}
var frontDoorOriginGroups = [
  {
    name: 'origingroup-${appGlobalEnvironment}-inspectorgadget'
    sampleSize: 4
    successfulSamplesRequired: 3
    probePath: '/'
    probeRequestType: 'HEAD'
    probeProtocol: 'Http'
    probeIntervalInSeconds: 100
  }
  {
    name: 'origingroup-${appGlobalEnvironment}-frontend'
    sampleSize: 4
    successfulSamplesRequired: 3
    probePath: '/'
    probeRequestType: 'HEAD'
    probeProtocol: 'Http'
    probeIntervalInSeconds: 100
  }
  {
    name: 'origingroup-${appGlobalEnvironment}-apigateway'
    sampleSize: 4
    successfulSamplesRequired: 3
    probePath: '/swagger'
    probeRequestType: 'HEAD'
    probeProtocol: 'Http'
    probeIntervalInSeconds: 100
  }
]
var frontDoorOrigins = [
  {
    name: 'origin-${appGlobalEnvironment}-inspectorgadget'
    hostName: replace('app-${appEnvironment}-inspectorgadget.azurewebsites.net', '-', '')
    httpPort: 80
    httpsPort: 443
    originHostHeader: replace('app-${appEnvironment}-inspectorgadget.azurewebsites.net', '-', '')
    priority: 1
    weight: 1000
  }
  {
    name: 'origin-${appGlobalEnvironment}-frontend'
    hostName: replace('app-${appEnvironment}-ade-frontend.azurewebsites.net', '-', '')
    httpPort: 80
    httpsPort: 443
    originHostHeader: replace('app-${appEnvironment}-ade-frontend.azurewebsites.net', '-', '')
    priority: 1
    weight: 1000
  }
  {
    name: 'origin-${appGlobalEnvironment}-apigateway'
    hostName: replace('app-${appEnvironment}-ade-apigateway.azurewebsites.net', '-', '')
    httpPort: 80
    httpsPort: 443
    originHostHeader: replace('app-${appEnvironment}-ade-apigateway.azurewebsites.net', '-', '')
    priority: 1
    weight: 1000
  }
]
var frontDoorSecretProperties = {
  name: 'secret-${appGlobalEnvironment}'
  type: 'CustomerCertificate'
  useLatestVersion: (keyVaultSecretVersion == '')
  secretVersion: keyVaultSecretVersion
  id: keyVault::keyVaultSecret.id
}
var frontDoorCustomDomains = [
  {
    name: 'domainName-${appGlobalEnvironment}-inspectorgadget'
    hostName: 'inspectorgadget.${rootDomainName}'
    certificateType: 'CustomerCertificate'
    minimumTlsVersion: 'TLS12'
  }
  {
    name: 'domainName-${appGlobalEnvironment}-frontend'
    hostName: 'ade-frontend-app.${rootDomainName}'
    certificateType: 'CustomerCertificate'
    minimumTlsVersion: 'TLS12'
  }
  {
    name: 'domainName-${appGlobalEnvironment}-apigateway'
    hostName: 'ade-apigateway-app.${rootDomainName}'
    certificateType: 'CustomerCertificate'
    minimumTlsVersion: 'TLS12'
  }
]
var frontDoorRoutes = [
  {
    name: 'route-${appGlobalEnvironment}-inspectorgadget'
  }
  {
    name: 'route-${appGlobalEnvironment}-frontend'
  }
  {
    name: 'route-${appGlobalEnvironment}-apigateway'
  }
]

// Variables - Front Door Dns Records
//////////////////////////////////////////////////
var frontDoorTxtRecords = [
  {
    name: '_dnsauth.inspectorgadget'
    ttl: 3600
    value: frontDoorModule.outputs.frontDoorCustomDomainVerificationIds[0].frontDoorCustomDomainVerificationId
  }
  {
    name: '_dnsauth.frontend-app'
    ttl: 3600
    value: frontDoorModule.outputs.frontDoorCustomDomainVerificationIds[0].frontDoorCustomDomainVerificationId
  }
  {
    name: '_dnsauth.apigateway-app'
    ttl: 3600
    value: frontDoorModule.outputs.frontDoorCustomDomainVerificationIds[0].frontDoorCustomDomainVerificationId
  }
]
var frontDoorCnameRecords = [
  {
    name: 'inspectorgadget'
    ttl: 3600
    cname: frontDoorModule.outputs.frontDoorEndpointHostName
  }
  {
    name: 'frontend-app'
    ttl: 3600
    cname: frontDoorModule.outputs.frontDoorEndpointHostName
  }
  {
    name: 'apigateway-app'
    ttl: 3600
    cname: frontDoorModule.outputs.frontDoorEndpointHostName
  }
]

// Variables - Private DNS
//////////////////////////////////////////////////
var appServicePrivateDnsZoneName = 'privatelink.azurewebsites.net'
var azureSqlPrivateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'

// Variables - Virtual Network Peering
//////////////////////////////////////////////////
var peeringProperties = {
  allowVirtualNetworkAccess: true
  allowForwardedTraffic: false
  allowGatewayTransit: false
  useRemoteGateways: false
}

// Variables - Network Security Group Flow Logs
//////////////////////////////////////////////////
var networkWatcherResourceGroupName = 'NetworkWatcherRG'

// Variables - Existing Resources
//////////////////////////////////////////////////
var applicationGatewayManagedIdentityName = 'id-${appEnvironment}-applicationGateway'
var eventHubNamespaceAuthorizationRuleName = 'RootManageSharedAccessKey'
var eventHubNamespaceName = 'evhns-${appEnvironment}-diagnostics'
var keyVaultName = 'kv-${appEnvironment}'
var keyVaultSecretName = 'certificate'
var logAnalyticsWorkspaceName = 'log-${appEnvironment}'
var storageAccountName = replace('sa-diag-${uniqueString(subscription().subscriptionId)}', '-', '')

// Existing Resource - Dns Zone
//////////////////////////////////////////////////
resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' existing = {
  scope: resourceGroup(dnsZoneResourceGroupName)
  name: rootDomainName
}

// Existing Resource - Event Hub Authorization Rule
//////////////////////////////////////////////////
resource eventHubNamespaceAuthorizationRule 'Microsoft.EventHub/namespaces/authorizationRules@2022-10-01-preview' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: '${eventHubNamespaceName}/${eventHubNamespaceAuthorizationRuleName}'
}

// Existing Resource - Key Vault
//////////////////////////////////////////////////
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  scope: resourceGroup(securityResourceGroupName)
  name: keyVaultName
  resource keyVaultSecret 'secrets' existing = {
    name: keyVaultSecretName
  }
}

// Existing Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: logAnalyticsWorkspaceName
}

// Existing Resource - Managed Identity - Application Gateway
//////////////////////////////////////////////////
resource applicationGatewayManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup(securityResourceGroupName)
  name: applicationGatewayManagedIdentityName
}

// Existing Resource - Storage Account - Diagnostics
//////////////////////////////////////////////////
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: storageAccountName
}

// Module - Storage Account
//////////////////////////////////////////////////
module storageAccountModule 'storage_account.bicep' = {
  name: 'storageAccountDeployment'
  params: {
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    storageAccountProperties: nsgFlowLogsStorageAccountProperties
    storageAccountName: nsgFlowLogsStorageAccountName
    tags: tags
  }
}

// Module - Nat Gateway
//////////////////////////////////////////////////
module natGatewayModule './nat_gateway.bicep' = {
  name: 'natGatewayDeployment'
  params: {
    location: location
    natGatewayName: natGatewayName
    natGatewayProperties: natGatewayProperties
    publicIpPrefixName: publicIpPrefixName
    publicIpPrefixProperties: publicIpPrefixProperties
    tags: tags
  }
}

// Module - Network Security Group
//////////////////////////////////////////////////
module networkSecurityGroupModule './network_security_group.bicep' = {
  name: 'networkSecurityGroupsDeployment'
  params: {
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    networkSecurityGroups: networkSecurityGroups
    storageAccountId: storageAccount.id
    tags: tags
  }
}

// Module - Route Table
//////////////////////////////////////////////////
module routeTableModule './route_table.bicep' = {
  name: 'routeTableDeployment'
  params: {
    routes: routes
    routeTableName: routeTableName
    location: location
    tags: tags
  }
}

// Module - Virtual Network
//////////////////////////////////////////////////
module virtualNetworkModule 'virtual_network.bicep' = {
  name: 'virtualNetworkDeployment'
  params: {
    applicationGatewaySubnetName: applicationGatewaySubnetName
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    hubVirtualNetworkName: hubVirtualNetworkName
    hubVirtualNetworkPrefix: hubVirtualNetworkPrefix
    hubVirtualNetworkSubnets: hubVirtualNetworkSubnets
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    spokeVirtualNetworkName: spokeVirtualNetworkName
    spokeVirtualNetworkPrefix: spokeVirtualNetworkPrefix
    spokeVirtualNetworkSubnets: spokeVirtualNetworkSubnets
    storageAccountId: storageAccount.id
    tags: tags
  }
}

// Module - Firewall
//////////////////////////////////////////////////
module firewallModule './firewall.bicep' = if (deployFirewall == true) {
  name: 'firewallDeployment'
  params: {
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    // firewallName: firewallName
    firewallProperties: firewallProperties
    firewallSubnetId: virtualNetworkModule.outputs.firewallSubnetId
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    // publicIpAddressName: firewallPublicIpAddressName
    publicIpAddressProperties: firewallPublicIpAddressProperties
    storageAccountId: storageAccount.id
    tags: tags
  }
}

// Module - Azure Bastion
//////////////////////////////////////////////////
module azureBastionModule './bastion.bicep' = {
  name: 'azureBastionDeployment'
  params: {
    bastionName: bastionName
    bastionSubnetId: virtualNetworkModule.outputs.bastionSubnetId
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    publicIpAddressProperties: bastionPublicIpAddressProperties
    storageAccountId: storageAccount.id
    tags: tags
  }
}

// Module - Application Gateway
//////////////////////////////////////////////////
module applicationGatewayModule 'application_gateway.bicep' = {
  name: 'applicationGatewayDeployment'
  params: {
    applicationGatewayProperties: applicationGatewayProperties
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    publicIpAddressProperties: applicationGatewayPublicIpAddressProperties
    sslCertificateData: keyVault.getSecret('certificate')
    sslCertificateDataPassword: sslCertificateDataPassword
    sslCertificateName: sslCertificateName
    storageAccountId: storageAccount.id
    tags: tags
  }
}

// Module - Front Door
//////////////////////////////////////////////////
module frontDoorModule 'front_door.bicep' = {
  name: 'frontDoorDeployment'
  params: {
    frontDoorCustomDomains: frontDoorCustomDomains
    frontDoorEndpointProperties: frontDoorEndpointProperties
    frontDoorOriginGroups: frontDoorOriginGroups
    frontDoorOrigins: frontDoorOrigins
    frontDoorProfileProperties: frontDoorProfileProperties
    frontDoorRoutes: frontDoorRoutes
    frontDoorSecretProperties: frontDoorSecretProperties
    tags: tags
  }
}

// Module - Front Door Dns Records
//////////////////////////////////////////////////
module frontDoorDnsRecordsModule 'front_door_dns.bicep' = {
  scope: resourceGroup(dnsZoneResourceGroupName)
  name: 'frontDoorDnsRecordsDeployment'
  params: {
    dnsCnameRecords: frontDoorCnameRecords
    dnsTxtRecords: frontDoorTxtRecords
    dnsZoneName: dnsZone.name
  }
}

// Module - Virtual Network Peering
//////////////////////////////////////////////////
module vnetPeeringVgwModule 'virtual_network_peering.bicep' = {
  name: 'vnetPeeringVgwDeployment'
  params: {
    hubVirtualNetworkId: virtualNetworkModule.outputs.hubVirtualNetworkId
    hubVirtualNetworkName: hubVirtualNetworkName
    peeringProperties: peeringProperties
    spokeVirtualNetworkId: virtualNetworkModule.outputs.spokeVirtualNetworkId
    spokeVirtualNetworkName: spokeVirtualNetworkName
  }
}

// Module - Private Dns
//////////////////////////////////////////////////
module privateDnsModule './private_dns.bicep' = {
  name: 'privateDnsDeployment'
  params: {
    appServicePrivateDnsZoneName: appServicePrivateDnsZoneName
    azureSqlPrivateDnsZoneName: azureSqlPrivateDnsZoneName
    hubVirtualNetworkId: virtualNetworkModule.outputs.hubVirtualNetworkId
    hubVirtualNetworkName: hubVirtualNetworkName
    spokeVirtualNetworkId: virtualNetworkModule.outputs.spokeVirtualNetworkId
    spokeVirtualNetworkName: spokeVirtualNetworkName
    tags: tags
  }
}

// Module - Network Security Group Flow Logs
// //////////////////////////////////////////////////
module nsgFlowLogsModule './network_security_group_flow_logs.bicep' = {
  scope: resourceGroup(networkWatcherResourceGroupName)
  name: 'nsgFlowLogsDeployment'
  params: {
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    networkSecurityGroupProperties: networkSecurityGroupModule.outputs.networkSecurityGroupProperties
    storageAccountId: storageAccountModule.outputs.storageAccountId
  }
}
