// Parameters
//////////////////////////////////////////////////
@description('The Fqdn of the ADE App Api Gateway App Service.')
param adeAppApiGatewayAppServiceFqdn string

@description('The Host Name of the ADE App Api Gateway App Service.')
param adeAppApiGatewayAppServiceHostName string

@description('The Host Name of the ADE App Api Gateway.')
param adeAppApiGatewayHostName string

@description('The Host Name of the ADE App Api Gateway Virtual Machine.')
param adeAppApiGatewayVmHostName string

@description('The Host Name of the ADE App Api Gateway VMSS.')
param adeAppApiGatewayVmssHostName string

@description('The Fqdn of the ADE App Frontend App Service.')
param adeAppFrontendAppServiceFqdn string

@description('The Host Name of the ADE App Frontend App Service.')
param adeAppFrontendAppServiceHostName string

@description('The Host Name of the ADE App Frontend.')
param adeAppFrontendHostName string

@description('The Host Name of the ADE App Frontend Virtual Machine.')
param adeAppFrontendVmHostName string

@description('The Host Name of the ADE App Frontend VMSS.')
param adeAppFrontendVmssHostName string

@description('The ID of the Application Gateway Managed Identity.')
param applicationGatewayManagedIdentityId string

@description('The name of the Application Gateway.')
param applicationGatewayName string

@description('The name of the Application Gateway Public IP Address.')
param applicationGatewayPublicIpAddressName string

@description('The ID of the Application Gateway Subnet')
param applicationGatewaySubnetId string

@description('The ID of the Diagnostics Storage Account.')
param diagnosticsStorageAccountId string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The Fqdn of the Inspector Gadget App Service.')
param inspectorGadgetAppServiceFqdn string

@description('The Host Name of the Inspector Gadget App Service.')
param inspectorGadgetAppServiceHostName string

@description('The Waf Policy Name of the Inspector Gadget App Service.')
param inspectorGadgetAppServiceWafPolicyName string

@description('The Waf Policy Rule Name of the Inspector Gadget App Service.')
param inspectorGadgetAppServiceWafPolicyRuleName string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The data of the SSL Certificate (stored in KeyVault.)')
@secure()
param sslCertificateData string

@description('The password of the SSL Certificate (stored in KeyVault.)')
param sslCertificateDataPassword string

@description('The name of the SSL Certificate (stored in KeyVault).')
param sslCertificateName string

// Variables
//////////////////////////////////////////////////
var adeAppApiGateway = {
  configuration: {
    backendPoolName: 'backendPool-ade-apigateway'
    fqdn: adeAppApiGatewayAppServiceFqdn
    healthProbeName: 'probe-ade-apigateway'
    hostName: adeAppApiGatewayHostName
    httpListenerName: 'listener-http-ade-apigateway'
    httpSettingName: 'httpsetting-ade-apigateway'
    httpsListenerName: 'listener-https-ade-apigateway'
    redirectionConfigName: 'redirectionconfig-ade-apigateway'
    redirectionRoutingRuleName: 'routingrule-redirection-ade-apigateway'
    routingRuleName: 'routingrule-ade-apigateway'
  }
}
var adeAppApiGatewayAppService = {
  configuration: {
    backendPoolName: 'backendPool-ade-apigateway-app'
    fqdn: adeAppApiGatewayAppServiceFqdn
    healthProbeName: 'probe-ade-apigateway-app'
    hostName: adeAppApiGatewayAppServiceHostName
    httpListenerName: 'listener-http-ade-apigateway-app'
    httpSettingName: 'httpsetting-ade-apigateway-app'
    httpsListenerName: 'listener-https-ade-apigateway-app'
    redirectionConfigName: 'redirectionconfig-ade-apigateway-app'
    redirectionRoutingRuleName: 'routingrule-redirection-ade-apigateway-app'
    routingRuleName: 'routingrule-ade-apigateway-app'
  }
}
var adeAppApiGatewayVm = {
  configuration: {
    backendPoolName: 'backendPool-ade-apigateway-vm'
    healthProbeName: 'probe-ade-apigateway-vm'
    hostName: adeAppApiGatewayVmHostName
    httpListenerName: 'listener-http-ade-apigateway-vm'
    httpSettingName: 'httpsetting-ade-apigateway-vm'
    httpsListenerName: 'listener-https-ade-apigateway-vm'
    redirectionConfigName: 'redirectionconfig-ade-apigateway-vm'
    redirectionRoutingRuleName: 'routingrule-redirection-ade-apigateway-vm'
    routingRuleName: 'routingrule-ade-apigateway-vm'
  }
}
var adeAppApiGatewayVmss = {
  configuration: {
    backendPoolName: 'backendPool-ade-apigateway-vmss'
    healthProbeName: 'probe-ade-apigateway-vmss'
    hostName: adeAppApiGatewayVmssHostName
    httpListenerName: 'listener-http-ade-apigateway-vmss'
    httpSettingName: 'httpsetting-ade-apigateway-vmss'
    httpsListenerName: 'listener-https-ade-apigateway-vmss'
    redirectionConfigName: 'redirectionconfig-ade-apigateway-vmss'
    redirectionRoutingRuleName: 'routingrule-redirection-ade-apigateway-vmss'
    routingRuleName: 'routingrule-ade-apigateway-vmss'
  }
}
var adeAppFrontend = {
  configuration: {
    backendPoolName: 'backendPool-ade-frontend'
    fqdn: adeAppFrontendAppServiceFqdn
    healthProbeName: 'probe-ade-frontend'
    hostName: adeAppFrontendHostName
    httpListenerName: 'listener-http-ade-frontend'
    httpSettingName: 'httpsetting-ade-frontend'
    httpsListenerName: 'listener-https-ade-frontend'
    redirectionConfigName: 'redirectionconfig-ade-frontend'
    redirectionRoutingRuleName: 'routingrule-redirection-ade-frontend'
    routingRuleName: 'routingrule-ade-frontend'
  }
}
var adeAppFrontendAppService = {
  configuration: {
    backendPoolName: 'backendPool-ade-frontend-app'
    fqdn: adeAppFrontendAppServiceFqdn
    healthProbeName: 'probe-ade-frontend-app'
    hostName: adeAppFrontendAppServiceHostName
    httpListenerName: 'listener-http-ade-frontend-app'
    httpSettingName: 'httpsetting-ade-frontend-app'
    httpsListenerName: 'listener-https-ade-frontend-app'
    redirectionConfigName: 'redirectionconfig-ade-frontend-app'
    redirectionRoutingRuleName: 'routingrule-redirection-ade-frontend-app'
    routingRuleName: 'routingrule-ade-frontend-app'
  }
}
var adeAppFrontendVm = {
  configuration: {
    backendPoolName: 'backendPool-ade-frontend-vm'
    healthProbeName: 'probe-ade-frontend-vm'
    hostName: adeAppFrontendVmHostName
    httpListenerName: 'listener-http-ade-frontend-vm'
    httpSettingName: 'httpsetting-ade-frontend-vm'
    httpsListenerName: 'listener-https-ade-frontend-vm'
    redirectionConfigName: 'redirectionconfig-ade-frontend-vm'
    redirectionRoutingRuleName: 'routingrule-redirection-ade-frontend-vm'
    routingRuleName: 'routingrule-ade-frontend-vm'
  }
}
var adeAppFrontendVmss = {
  configuration: {
    backendPoolName: 'backendPool-ade-frontend-vmss'
    healthProbeName: 'probe-ade-frontend-vmss'
    hostName: adeAppFrontendVmssHostName
    httpListenerName: 'listener-http-ade-frontend-vmss'
    httpSettingName: 'httpsetting-ade-frontend-vmss'
    httpsListenerName: 'listener-https-ade-frontend-vmss'
    redirectionConfigName: 'redirectionconfig-ade-frontend-vmss'
    redirectionRoutingRuleName: 'routingrule-redirection-ade-frontend-vmss'
    routingRuleName: 'routingrule-ade-frontend-vmss'
  }
}
var inspectorGadgetAppService = {
  configuration: {
    backendPoolName: 'backendPool-inspectorgadget'
    fqdn: inspectorGadgetAppServiceFqdn
    healthProbeName: 'probe-inspectorgadget'
    hostName: inspectorGadgetAppServiceHostName
    httpListenerName: 'listener-http-inspectorgadget'
    httpSettingName: 'httpsetting-inspectorgadget'
    httpsListenerName: 'listener-https-inspectorgadget'
    redirectionConfigName: 'redirectionconfig-inspectorgadget'
    redirectionRoutingRuleName: 'routingrule-redirection-inspectorgadget'
    routingRuleName: 'routingrule-inspectorgadget'
    wafPolicyName: inspectorGadgetAppServiceWafPolicyName
    wafPolicyRuleName: inspectorGadgetAppServiceWafPolicyRuleName
  }
}
var location = resourceGroup().location
var tags = {
  environment: 'production'
  function: 'networking'
  costCenter: 'it'
}

// Resource - Public Ip Address - Application Gateway
//////////////////////////////////////////////////
resource applicationGatewayPublicIpAddress 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: applicationGatewayPublicIpAddressName
  location: location
  tags: tags
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

// Resource - Public Ip Address - Diagnostic Settings - Application Gateway
//////////////////////////////////////////////////
resource applicationGatewayPublicIpAddressDiagnostics 'Microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: applicationGatewayPublicIpAddress
  name: '${applicationGatewayPublicIpAddress.name}-diagnostics'
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

// Resource - Waf Policy - Inspector Gadget
//////////////////////////////////////////////////
resource inspectorGadgetWafPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2020-11-01' = {
  name: inspectorGadgetAppService.configuration.wafPolicyName
  location: location
  tags: tags
  properties: {
    customRules: [
      {
        name: inspectorGadgetAppService.configuration.wafPolicyRuleName
        priority: 1
        ruleType: 'MatchRule'
        action: 'Allow'
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'RemoteAddr'
              }
            ]
            operator: 'IPMatch'
            negationConditon: false
            matchValues: [
              applicationGatewayPublicIpAddress.properties.ipAddress
            ]
            transforms: []
          }
        ]
      }
    ]
    policySettings: {
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
      state: 'Enabled'
      mode: 'Detection'
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.1'
          ruleGroupOverrides: []
        }
      ]
      exclusions: []
    }
  }
}

// Resource - Application Gateway
//////////////////////////////////////////////////
resource applicationGateway 'Microsoft.Network/applicationGateways@2020-11-01' = {
  name: applicationGatewayName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: 1
    }
    enableHttp2: false
    sslCertificates: [
      {
        name: sslCertificateName
        properties: {
          data: sslCertificateData
          password: sslCertificateDataPassword
        }
      }
    ]
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIPConfig'
        properties: {
          subnet: {
            id: applicationGatewaySubnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'frontendIpConfiguration'
        properties: {
          publicIPAddress: {
            id: applicationGatewayPublicIpAddress.id
          }
        }
      }
    ]
    frontendPorts: [
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
    backendAddressPools: [
      {
        name: adeAppApiGateway.configuration.backendPoolName
        properties: {
          backendAddresses: [
            {
              fqdn: adeAppApiGateway.configuration.fqdn
            }
          ]
        }
      }
      {
        name: adeAppApiGatewayAppService.configuration.backendPoolName
        properties: {
          backendAddresses: [
            {
              fqdn: adeAppApiGatewayAppService.configuration.fqdn
            }
          ]
        }
      }
      {
        name: adeAppApiGatewayVm.configuration.backendPoolName
        properties: {}
      }
      {
        name: adeAppApiGatewayVmss.configuration.backendPoolName
        properties: {}
      }
      {
        name: adeAppFrontend.configuration.backendPoolName
        properties: {
          backendAddresses: [
            {
              fqdn: adeAppFrontend.configuration.fqdn
            }
          ]
        }
      }
      {
        name: adeAppFrontendAppService.configuration.backendPoolName
        properties: {
          backendAddresses: [
            {
              fqdn: adeAppFrontendAppService.configuration.fqdn
            }
          ]
        }
      }
      {
        name: adeAppFrontendVm.configuration.backendPoolName
        properties: {}
      }
      {
        name: adeAppFrontendVmss.configuration.backendPoolName
        properties: {}
      }
      {
        name: inspectorGadgetAppService.configuration.backendPoolName
        properties: {
          backendAddresses: [
            {
              fqdn: inspectorGadgetAppService.configuration.fqdn
            }
          ]
        }
      }
    ]
    probes: [
      {
        name: adeAppApiGateway.configuration.healthProbeName
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
        name: adeAppApiGatewayAppService.configuration.healthProbeName
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
        name: adeAppApiGatewayVm.configuration.healthProbeName
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
        name: adeAppApiGatewayVmss.configuration.healthProbeName
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
        name: adeAppFrontend.configuration.healthProbeName
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
        name: adeAppFrontendAppService.configuration.healthProbeName
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
        name: adeAppFrontendVm.configuration.healthProbeName
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
        name: adeAppFrontendVmss.configuration.healthProbeName
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
        name: inspectorGadgetAppService.configuration.healthProbeName
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
    backendHttpSettingsCollection: [
      {
        name: adeAppApiGateway.configuration.httpSettingName
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          pickHostNameFromBackendAddress: true
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, adeAppApiGateway.configuration.healthProbeName)
          }
        }
      }
      {
        name: adeAppApiGatewayAppService.configuration.httpSettingName
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          pickHostNameFromBackendAddress: true
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, adeAppApiGatewayAppService.configuration.healthProbeName)
          }
        }
      }
      {
        name: adeAppApiGatewayVm.configuration.httpSettingName
        properties: {
          port: 8080
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          pickHostNameFromBackendAddress: true
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, adeAppApiGatewayVm.configuration.healthProbeName)
          }
        }
      }
      {
        name: adeAppApiGatewayVmss.configuration.httpSettingName
        properties: {
          port: 8080
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          pickHostNameFromBackendAddress: true
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, adeAppApiGatewayVmss.configuration.healthProbeName)
          }
        }
      }
      {
        name: adeAppFrontend.configuration.httpSettingName
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          pickHostNameFromBackendAddress: true
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, adeAppFrontend.configuration.healthProbeName)
          }
        }
      }
      {
        name: adeAppFrontendAppService.configuration.httpSettingName
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          pickHostNameFromBackendAddress: true
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, adeAppFrontendAppService.configuration.healthProbeName)
          }
        }
      }
      {
        name: adeAppFrontendVm.configuration.httpSettingName
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          pickHostNameFromBackendAddress: true
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, adeAppFrontendVm.configuration.healthProbeName)
          }
        }
      }
      {
        name: adeAppFrontendVmss.configuration.httpSettingName
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          pickHostNameFromBackendAddress: true
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, adeAppFrontendVmss.configuration.healthProbeName)
          }
        }
      }
      {
        name: inspectorGadgetAppService.configuration.httpSettingName
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          pickHostNameFromBackendAddress: true
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, inspectorGadgetAppService.configuration.healthProbeName)
          }
        }
      }
    ]
    httpListeners: [
      {
        name: adeAppApiGateway.configuration.httpListenerName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontendIpConfiguration')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_80')
          }
          protocol: 'Http'
          hostName: adeAppApiGateway.configuration.hostName
          requireServerNameIndication: false
        }
      }
      {
        name: adeAppApiGateway.configuration.httpsListenerName
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
          hostName: adeAppApiGateway.configuration.hostName
          requireServerNameIndication: false
        }
      }
      {
        name: adeAppApiGatewayAppService.configuration.httpListenerName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontendIpConfiguration')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_80')
          }
          protocol: 'Http'
          hostName: adeAppApiGatewayAppService.configuration.hostName
          requireServerNameIndication: false
        }
      }
      {
        name: adeAppApiGatewayAppService.configuration.httpsListenerName
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
          hostName: adeAppApiGatewayAppService.configuration.hostName
          requireServerNameIndication: false
        }
      }
      {
        name: adeAppApiGatewayVm.configuration.httpListenerName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontendIpConfiguration')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_80')
          }
          protocol: 'Http'
          hostName: adeAppApiGatewayVm.configuration.hostName
          requireServerNameIndication: false
        }
      }
      {
        name: adeAppApiGatewayVm.configuration.httpsListenerName
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
          hostName: adeAppApiGatewayVm.configuration.hostName
          requireServerNameIndication: false
        }
      }
      {
        name: adeAppApiGatewayVmss.configuration.httpListenerName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontendIpConfiguration')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_80')
          }
          protocol: 'Http'
          hostName: adeAppApiGatewayVmss.configuration.hostName
          requireServerNameIndication: false
        }
      }
      {
        name: adeAppApiGatewayVmss.configuration.httpsListenerName
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
          hostName: adeAppApiGatewayVmss.configuration.hostName
          requireServerNameIndication: false
        }
      }
      {
        name: adeAppFrontend.configuration.httpListenerName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontendIpConfiguration')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_80')
          }
          protocol: 'Http'
          hostName: adeAppFrontend.configuration.hostName
          requireServerNameIndication: false
        }
      }
      {
        name: adeAppFrontend.configuration.httpsListenerName
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
          hostName: adeAppFrontend.configuration.hostName
          requireServerNameIndication: false
        }
      }
      {
        name: adeAppFrontendAppService.configuration.httpListenerName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontendIpConfiguration')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_80')
          }
          protocol: 'Http'
          hostName: adeAppFrontendAppService.configuration.hostName
          requireServerNameIndication: false
        }
      }
      {
        name: adeAppFrontendAppService.configuration.httpsListenerName
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
          hostName: adeAppFrontendAppService.configuration.hostName
          requireServerNameIndication: false
        }
      }
      {
        name: adeAppFrontendVm.configuration.httpListenerName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontendIpConfiguration')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_80')
          }
          protocol: 'Http'
          hostName: adeAppFrontendVm.configuration.hostName
          requireServerNameIndication: false
        }
      }
      {
        name: adeAppFrontendVm.configuration.httpsListenerName
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
          hostName: adeAppFrontendVm.configuration.hostName
          requireServerNameIndication: false
        }
      }
      {
        name: adeAppFrontendVmss.configuration.httpListenerName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontendIpConfiguration')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_80')
          }
          protocol: 'Http'
          hostName: adeAppFrontendVmss.configuration.hostName
          requireServerNameIndication: false
        }
      }
      {
        name: adeAppFrontendVmss.configuration.httpsListenerName
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
          hostName: adeAppFrontendVmss.configuration.hostName
          requireServerNameIndication: false
        }
      }
      {
        name: inspectorGadgetAppService.configuration.httpListenerName
        properties: {
          firewallPolicy: {
            id: inspectorGadgetWafPolicy.id
          }
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontendIpConfiguration')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_80')
          }
          protocol: 'Http'
          hostName: inspectorGadgetAppService.configuration.hostName
          requireServerNameIndication: false
        }
      }
      {
        name: inspectorGadgetAppService.configuration.httpsListenerName
        properties: {
          firewallPolicy: {
            id: inspectorGadgetWafPolicy.id
          }
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
          hostName: inspectorGadgetAppService.configuration.hostName
          requireServerNameIndication: false
        }
      }
    ]
    redirectConfigurations: [
      {
        name: adeAppApiGateway.configuration.redirectionConfigName
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppApiGateway.configuration.httpsListenerName)
          }
        }
      }
      {
        name: adeAppApiGatewayAppService.configuration.redirectionConfigName
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppApiGatewayAppService.configuration.httpsListenerName)
          }
        }
      }
      {
        name: adeAppApiGatewayVm.configuration.redirectionConfigName
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppApiGatewayVm.configuration.httpsListenerName)
          }
        }
      }
      {
        name: adeAppApiGatewayVmss.configuration.redirectionConfigName
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppApiGatewayVmss.configuration.httpsListenerName)
          }
        }
      }
      {
        name: adeAppFrontend.configuration.redirectionConfigName
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppFrontend.configuration.httpsListenerName)
          }
        }
      }
      {
        name: adeAppFrontendAppService.configuration.redirectionConfigName
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppFrontendAppService.configuration.httpsListenerName)
          }
        }
      }
      {
        name: adeAppFrontendVm.configuration.redirectionConfigName
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppFrontendVm.configuration.httpsListenerName)
          }
        }
      }
      {
        name: adeAppFrontendVmss.configuration.redirectionConfigName
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppFrontendVmss.configuration.httpsListenerName)
          }
        }
      }
      {
        name: inspectorGadgetAppService.configuration.redirectionConfigName
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, inspectorGadgetAppService.configuration.httpsListenerName)
          }
        }
      }
    ]
    requestRoutingRules: [
      {
        name: adeAppApiGateway.configuration.routingRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppApiGateway.configuration.httpsListenerName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, adeAppApiGateway.configuration.backendPoolName)
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, adeAppApiGateway.configuration.httpSettingName)
          }
        }
      }
      {
        name: adeAppApiGateway.configuration.redirectionRoutingRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppApiGateway.configuration.httpListenerName)
          }
          redirectConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, adeAppApiGateway.configuration.redirectionConfigName)
          }
        }
      }
      {
        name: adeAppApiGatewayAppService.configuration.routingRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppApiGatewayAppService.configuration.httpsListenerName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, adeAppApiGatewayAppService.configuration.backendPoolName)
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, adeAppApiGatewayAppService.configuration.httpSettingName)
          }
        }
      }
      {
        name: adeAppApiGatewayAppService.configuration.redirectionRoutingRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppApiGatewayAppService.configuration.httpListenerName)
          }
          redirectConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, adeAppApiGatewayAppService.configuration.redirectionConfigName)
          }
        }
      }
      {
        name: adeAppApiGatewayVm.configuration.routingRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppApiGatewayVm.configuration.httpsListenerName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, adeAppApiGatewayVm.configuration.backendPoolName)
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, adeAppApiGatewayVm.configuration.httpSettingName)
          }
        }
      }
      {
        name: adeAppApiGatewayVm.configuration.redirectionRoutingRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppApiGatewayVm.configuration.httpListenerName)
          }
          redirectConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, adeAppApiGatewayVm.configuration.redirectionConfigName)
          }
        }
      }
      {
        name: adeAppApiGatewayVmss.configuration.routingRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppApiGatewayVmss.configuration.httpsListenerName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, adeAppApiGatewayVmss.configuration.backendPoolName)
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, adeAppApiGatewayVmss.configuration.httpSettingName)
          }
        }
      }
      {
        name: adeAppApiGatewayVmss.configuration.redirectionRoutingRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppApiGatewayVmss.configuration.httpListenerName)
          }
          redirectConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, adeAppApiGatewayVmss.configuration.redirectionConfigName)
          }
        }
      }
      {
        name: adeAppFrontend.configuration.routingRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppFrontend.configuration.httpsListenerName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, adeAppFrontend.configuration.backendPoolName)
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, adeAppFrontend.configuration.httpSettingName)
          }
        }
      }
      {
        name: adeAppFrontend.configuration.redirectionRoutingRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppFrontend.configuration.httpListenerName)
          }
          redirectConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, adeAppFrontend.configuration.redirectionConfigName)
          }
        }
      }
      {
        name: adeAppFrontendAppService.configuration.routingRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppFrontendAppService.configuration.httpsListenerName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, adeAppFrontendAppService.configuration.backendPoolName)
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, adeAppFrontendAppService.configuration.httpSettingName)
          }
        }
      }
      {
        name: adeAppFrontendAppService.configuration.redirectionRoutingRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppFrontendAppService.configuration.httpListenerName)
          }
          redirectConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, adeAppFrontendAppService.configuration.redirectionConfigName)
          }
        }
      }
      {
        name: adeAppFrontendVm.configuration.routingRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppFrontendVm.configuration.httpsListenerName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, adeAppFrontendVm.configuration.backendPoolName)
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, adeAppFrontendVm.configuration.httpSettingName)
          }
        }
      }
      {
        name: adeAppFrontendVm.configuration.redirectionRoutingRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppFrontendVm.configuration.httpListenerName)
          }
          redirectConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, adeAppFrontendVm.configuration.redirectionConfigName)
          }
        }
      }
      {
        name: adeAppFrontendVmss.configuration.routingRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppFrontendVmss.configuration.httpsListenerName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, adeAppFrontendVmss.configuration.backendPoolName)
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, adeAppFrontendVmss.configuration.httpSettingName)
          }
        }
      }
      {
        name: adeAppFrontendVmss.configuration.redirectionRoutingRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppFrontendVmss.configuration.httpListenerName)
          }
          redirectConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, adeAppFrontendVmss.configuration.redirectionConfigName)
          }
        }
      }
      {
        name: inspectorGadgetAppService.configuration.routingRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, inspectorGadgetAppService.configuration.httpsListenerName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, inspectorGadgetAppService.configuration.backendPoolName)
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, inspectorGadgetAppService.configuration.httpSettingName)
          }
        }
      }
      {
        name: inspectorGadgetAppService.configuration.redirectionRoutingRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, inspectorGadgetAppService.configuration.httpListenerName)
          }
          redirectConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, inspectorGadgetAppService.configuration.redirectionConfigName)
          }
        }
      }
    ]
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Prevention'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.0'
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${applicationGatewayManagedIdentityId}': {}
    }
  }
}

// Resource - Application Gateway - Diagnostic Settings
//////////////////////////////////////////////////
resource applicationGatewayDiagnostics 'Microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: applicationGateway
  name: '${applicationGateway.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'ApplicationGatewayAccessLog'
        enabled: true
      }
      {
        category: 'ApplicationGatewayPerformanceLog'
        enabled: true
      }
      {
        category: 'ApplicationGatewayFirewallLog'
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

// Outputs
//////////////////////////////////////////////////
output adeAppApiGatewayAppServiceHostName string = adeAppApiGatewayAppService.configuration.hostName
output adeAppApiGatewayBackendPoolId string = resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, adeAppApiGateway.configuration.backendPoolName)
output adeAppApiGatewayVmBackendPoolId string = resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, adeAppApiGatewayVm.configuration.backendPoolName)
output adeAppApiGatewayVmHostName string = adeAppApiGatewayVm.configuration.hostName
output adeAppApiGatewayVmssBackendPoolId string = resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, adeAppApiGatewayVmss.configuration.backendPoolName)
output adeAppFrontendBackendPoolId string = resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, adeAppFrontend.configuration.backendPoolName)
output adeAppFrontendVmBackendPoolId string = resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, adeAppFrontendVm.configuration.backendPoolName)
output adeAppFrontendVmssBackendPoolId string = resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, adeAppFrontendVmss.configuration.backendPoolName)
