// parameters
param location string
param logAnalyticsWorkspaceId string
<<<<<<< HEAD
param applicationGatewaySubnetId string
param applicationGatewayPublicIpAddressName string
param inspectorGadgetWafPolicyName string
param applicationGatewayName string

// variables
var sslCertificateName = ''
var sslCertificateData = ''
var sslCertificateDataPassword = ''

=======
param sslCertificateName string
param sslCertificateData string
param sslCertificateDataPassword string
param applicationGatewaySubnetId string
param applicationGatewayPublicIpAddressName string
param inspectorGadgetAppServiceWafPolicyName string
param applicationGatewayName string
param adeAppFrontEndAppServiceFqdn string
param adeAppFrontEndAppServiceHostName string
param adeAppApiGatewayAppServiceFqdn string
param adeAppApiGatewayAppServiceHostName string
param inspectorGadgetAppServiceFqdn string
param inspectorGadgetAppServiceHostName string
param nTierHostName string
param applicationGatewayManagedIdentity string

// variables
>>>>>>> origin/dev
var applicationGatewayFrontendIPConfigurationName = 'applicationGatewayFrontendIPConfiguration'
var applicationGatewayFrontendPortHttp = 'port_80'
var applicationGatewayFrontendPortHttps = 'port_443'

var adeAppFrontEndAppServiceBackendPoolName = 'backendPool-ade-frontend'
<<<<<<< HEAD
var adeAppFrontEndAppServiceFqdn = ''
var adeAppFrontEndAppServiceProbeName = ''
var adeAppFrontEndAppServiceHttpSettingName = ''
var adeAppFrontEndAppServiceHttpListenerName = ''
var adeAppFrontEndAppServiceHttpsListenerName = ''
var adeAppFrontEndAppServiceHostName = ''
var adeAppFrontEndAppServiceRedirectionConfigName = ''
var adeAppFrontEndAppServiceRuleName = ''
var adeAppFrontEndAppServiceRedirectionRuleName = ''

var adeAppApiGatewayAppServiceBackendPoolName = 'backendPool-ade-apigateway'
var adeAppApiGatewayAppServiceFqdn = ''
var adeAppApiGatewayAppServiceProbeName = ''
var adeAppApiGatewayAppServiceHttpSettingName = ''
var adeAppApiGatewayAppServiceHttpListenerName = ''
var adeAppApiGatewayAppServiceHttpsListenerName = ''
var adeAppApiGatewayAppServiceHostName = ''
var adeAppApiGatewayAppServiceRedirectionConfigName = ''
var adeAppApiGatewayAppServiceRuleName = ''
var adeAppApiGatewayAppServiceRedirectionRuleName = ''

var applicationGatewayUserAssignedManagedIdentity = ''
=======
var adeAppFrontEndAppServiceProbeName = 'probe-ade-frontend'
var adeAppFrontEndAppServiceHttpSettingName = 'httpsetting-ade-frontend'
var adeAppFrontEndAppServiceHttpListenerName = 'listener-http-ade-frontend'
var adeAppFrontEndAppServiceHttpsListenerName = 'listener-https-ade-frontend'
var adeAppFrontEndAppServiceRedirectionConfigName = 'redirectionconfig-ade-frontend'
var adeAppFrontEndAppServiceRuleName = 'routingrule-ade-frontend'
var adeAppFrontEndAppServiceRedirectionRuleName = 'routingrule-redirection--ade-frontend'

var adeAppApiGatewayAppServiceBackendPoolName = 'backendPool-ade-apigateway'
var adeAppApiGatewayAppServiceProbeName = 'probe-ade-apigateway'
var adeAppApiGatewayAppServiceHttpSettingName = 'httpsetting-ade-apigateway'
var adeAppApiGatewayAppServiceHttpListenerName = 'listener-http-ade-apigateway'
var adeAppApiGatewayAppServiceHttpsListenerName = 'listener-https-ade-apigateway'
var adeAppApiGatewayAppServiceRedirectionConfigName = 'redirectionconfig-ade-apigateway'
var adeAppApiGatewayAppServiceRuleName = 'routingrule-ade-apigateway'
var adeAppApiGatewayAppServiceRedirectionRuleName = 'routingrule-redirection--ade-apigateway'

var inspectorGadgetAppServiceWafPolicyRuleName = 'inspectorgadget'
var inspectorGadgetAppServiceBackendPoolName = 'backendPool-inspectorgadget'
var inspectorGadgetAppServiceProbeName = 'probe-inspectorgadget'
var inspectorGadgetAppServiceHttpSettingName = 'httpsetting-inspectorgadget'
var inspectorGadgetAppServiceHttpListenerName = 'listener-http-inspectorgadget'
var inspectorGadgetAppServiceHttpsListenerName = 'listener-https-inspectorgadget'
var inspectorGadgetAppServiceRedirectionConfigName = 'redirectionconfig-inspectorgadget'
var inspectorGadgetAppServiceRuleName = 'routingrule-inspectorgadget'
var inspectorGadgetAppServiceRedirectionRuleName = 'routingrule-redirection--inspectorgadget'

var nTierWafPolicyRuleName = 'ntier'
var nTierBackendPoolName = 'backendPool-ntier'
var nTierProbeName = 'probe-ntier'
var nTierHttpSettingName = 'httpsetting-ntier'
var nTierHttpListenerName = 'listener-http-ntier'
var nTierHttpsListenerName = 'listener-https-ntier'
var nTierRedirectionConfigName = 'redirectionconfig-ntier'
var nTierRuleName = 'routingrule-ntier'
var nTierRedirectionRuleName = 'routingrule-redirection--ntier'
>>>>>>> origin/dev

// variables
var environmentName = 'production'
var functionName = 'networking'
var costCenterName = 'it'

// resource - public ip address - application gateway
resource applicationGatewayPublicIpAddress 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: applicationGatewayPublicIpAddressName
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

// resource - public ip address - diagnostic settings - application gateway
resource applicationGatewayPublicIpAddressDiagnostics 'Microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: applicationGatewayPublicIpAddress
  name: '${applicationGatewayPublicIpAddress.name}-diagnostics'
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

// resource - waf policy - inspector gadget
resource inspectorGadgetWafPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2020-11-01' = {
<<<<<<< HEAD
  name: inspectorGadgetWafPolicyName
=======
  name: inspectorGadgetAppServiceWafPolicyName
>>>>>>> origin/dev
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    customRules: [
      {
<<<<<<< HEAD
        name: 'inspectorgadget'
=======
        name: inspectorGadgetAppServiceWafPolicyRuleName
>>>>>>> origin/dev
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
          ruleSetVersion: '3.0'
          ruleGroupOverrides: []
        }
      ]
      exclusions: []
    }
  }
}

// resource - application gateway
resource applicationGateway 'Microsoft.Network/applicationGateways@2020-11-01' = {
  name: applicationGatewayName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
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
        name: applicationGatewayFrontendIPConfigurationName
        properties: {
          publicIPAddress: {
<<<<<<< HEAD
            id: applicationGatewayPublicIpAddress.properties.ipAddress
=======
            id: applicationGatewayPublicIpAddress.id
>>>>>>> origin/dev
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: applicationGatewayFrontendPortHttp
        properties: {
          port: 80
        }
      }
      {
        name: applicationGatewayFrontendPortHttps
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: adeAppFrontEndAppServiceBackendPoolName
        properties: {
          backendAddresses: [
            {
              fqdn: adeAppFrontEndAppServiceFqdn
            }
          ]
        }
      }
      {
        name: adeAppApiGatewayAppServiceBackendPoolName
        properties: {
          backendAddresses: [
            {
              fqdn: adeAppApiGatewayAppServiceFqdn
            }
          ]
        }
      }
<<<<<<< HEAD
=======
      {
        name: inspectorGadgetAppServiceBackendPoolName
        properties: {
          backendAddresses: [
            {
              fqdn: inspectorGadgetAppServiceFqdn
            }
          ]
        }
      }
      {
        name: nTierBackendPoolName
        properties: {}
      }
>>>>>>> origin/dev
    ]
    probes: [
      {
        name: adeAppFrontEndAppServiceProbeName
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
        name: adeAppApiGatewayAppServiceProbeName
        properties: {
          interval: 30
          path: '/'
          protocol: 'Http'
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
        }
      }
<<<<<<< HEAD
=======
      {
        name: inspectorGadgetAppServiceProbeName
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
        name: nTierProbeName
        properties: {
          interval: 30
          path: '/'
          protocol: 'Http'
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
        }
      }
>>>>>>> origin/dev
    ]
    backendHttpSettingsCollection: [
      {
        name: adeAppFrontEndAppServiceHttpSettingName
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          pickHostNameFromBackendAddress: true
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, adeAppFrontEndAppServiceProbeName)
          }
        }
      }
      {
        name: adeAppApiGatewayAppServiceHttpSettingName
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          pickHostNameFromBackendAddress: true
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, adeAppApiGatewayAppServiceProbeName)
          }
        }
      }
<<<<<<< HEAD
=======
      {
        name: inspectorGadgetAppServiceHttpSettingName
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          pickHostNameFromBackendAddress: true
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, inspectorGadgetAppServiceProbeName)
          }
        }
      }
      {
        name: nTierHttpSettingName
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          pickHostNameFromBackendAddress: true
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, nTierProbeName)
          }
        }
      }
>>>>>>> origin/dev
    ]
    httpListeners: [
      {
        name: adeAppFrontEndAppServiceHttpListenerName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, applicationGatewayFrontendIPConfigurationName)
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, applicationGatewayFrontendPortHttp)
          }
          protocol: 'Http'
          hostName: adeAppFrontEndAppServiceHostName
          requireServerNameIndication: false
        }
      }
      {
        name: adeAppFrontEndAppServiceHttpsListenerName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, applicationGatewayFrontendIPConfigurationName)
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, applicationGatewayFrontendPortHttps)
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGatewayName, sslCertificateName)
          }
          hostName: adeAppFrontEndAppServiceHostName
          requireServerNameIndication: false
        }
      }
      {
        name: adeAppApiGatewayAppServiceHttpListenerName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, applicationGatewayFrontendIPConfigurationName)
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, applicationGatewayFrontendPortHttp)
          }
          protocol: 'Http'
          hostName: adeAppApiGatewayAppServiceHostName
          requireServerNameIndication: false
        }
      }
      {
        name: adeAppApiGatewayAppServiceHttpsListenerName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, applicationGatewayFrontendIPConfigurationName)
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, applicationGatewayFrontendPortHttps)
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGatewayName, sslCertificateName)
          }
          hostName: adeAppApiGatewayAppServiceHostName
          requireServerNameIndication: false
        }
      }
<<<<<<< HEAD
=======
      {
        name: inspectorGadgetAppServiceHttpListenerName
        properties: {
          firewallPolicy: {
            id: inspectorGadgetWafPolicy.id
          }
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, applicationGatewayFrontendIPConfigurationName)
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, applicationGatewayFrontendPortHttp)
          }
          protocol: 'Http'
          hostName: inspectorGadgetAppServiceHostName
          requireServerNameIndication: false
        }
      }
      {
        name: inspectorGadgetAppServiceHttpsListenerName
        properties: {
          firewallPolicy: {
            id: inspectorGadgetWafPolicy.id
          }
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, applicationGatewayFrontendIPConfigurationName)
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, applicationGatewayFrontendPortHttps)
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGatewayName, sslCertificateName)
          }
          hostName: inspectorGadgetAppServiceHostName
          requireServerNameIndication: false
        }
      }
      {
        name: nTierHttpListenerName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, applicationGatewayFrontendIPConfigurationName)
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, applicationGatewayFrontendPortHttp)
          }
          protocol: 'Http'
          hostName: nTierHostName
          requireServerNameIndication: false
        }
      }
      {
        name: nTierHttpsListenerName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, applicationGatewayFrontendIPConfigurationName)
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, applicationGatewayFrontendPortHttps)
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGatewayName, sslCertificateName)
          }
          hostName: nTierHostName
          requireServerNameIndication: false
        }
      }
>>>>>>> origin/dev
    ]
    redirectConfigurations: [
      {
        name: adeAppFrontEndAppServiceRedirectionConfigName
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppFrontEndAppServiceHttpsListenerName)
          }
        }
      }
      {
        name: adeAppApiGatewayAppServiceRedirectionConfigName
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppApiGatewayAppServiceHttpsListenerName)
          }
        }
      }
<<<<<<< HEAD
=======
      {
        name: inspectorGadgetAppServiceRedirectionConfigName
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, inspectorGadgetAppServiceHttpsListenerName)
          }
        }
      }
      {
        name: nTierRedirectionConfigName
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, nTierHttpsListenerName)
          }
        }
      }
>>>>>>> origin/dev
    ]
    requestRoutingRules: [
      {
        name: adeAppFrontEndAppServiceRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppFrontEndAppServiceHttpsListenerName)
          }
          backendAddressPool: {
<<<<<<< HEAD
            id: resourceId('Microsoft.Network/backendAddressPools/httpListeners', applicationGatewayName, adeAppFrontEndAppServiceBackendPoolName)
=======
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, adeAppFrontEndAppServiceBackendPoolName)
>>>>>>> origin/dev
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, adeAppFrontEndAppServiceHttpSettingName)
          }
        }
      }
      {
        name: adeAppFrontEndAppServiceRedirectionRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppFrontEndAppServiceHttpListenerName)
          }
          redirectConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, adeAppFrontEndAppServiceRedirectionConfigName)
          }
        }
      }
<<<<<<< HEAD
=======
      {
        name: adeAppApiGatewayAppServiceRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppApiGatewayAppServiceHttpsListenerName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, adeAppApiGatewayAppServiceBackendPoolName)
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, adeAppApiGatewayAppServiceHttpSettingName)
          }
        }
      }
      {
        name: adeAppApiGatewayAppServiceRedirectionRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppApiGatewayAppServiceHttpListenerName)
          }
          redirectConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, adeAppApiGatewayAppServiceRedirectionConfigName)
          }
        }
      }
      {
        name: inspectorGadgetAppServiceRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, inspectorGadgetAppServiceHttpsListenerName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, inspectorGadgetAppServiceBackendPoolName)
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, inspectorGadgetAppServiceHttpSettingName)
          }
        }
      }
      {
        name: inspectorGadgetAppServiceRedirectionRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, inspectorGadgetAppServiceHttpListenerName)
          }
          redirectConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, inspectorGadgetAppServiceRedirectionConfigName)
          }
        }
      }
      {
        name: nTierRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, nTierHttpsListenerName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, nTierBackendPoolName)
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, nTierHttpSettingName)
          }
        }
      }
      {
        name: nTierRedirectionRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, nTierHttpListenerName)
          }
          redirectConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, nTierRedirectionConfigName)
          }
        }
      }
>>>>>>> origin/dev
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
<<<<<<< HEAD
      '${applicationGatewayUserAssignedManagedIdentity}': {}
=======
      '${applicationGatewayManagedIdentity}': {}
>>>>>>> origin/dev
    }
  }
}

// resource - application gateway - diagnostic settings
resource applicationGatewayDiagnostics 'Microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: applicationGateway
  name: '${applicationGateway.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'ApplicationGatewayAccessLog'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'ApplicationGatewayPerformanceLog'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'ApplicationGatewayFirewallLog'
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
<<<<<<< HEAD
=======

// outputs
output nTierBackendPoolId string = resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, nTierBackendPoolName)
>>>>>>> origin/dev
