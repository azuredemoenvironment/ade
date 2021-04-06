// parameters
param location string = resourceGroup().location
param aliasRegion string

// variables
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
var containerInsights = {
  name: 'ContainerInsights(${logAnalyticsWorkspaceName})'
  galleryName: 'ContainerInsights'
}
var keyVaultAnalytics = {
  name: 'KeyVaultAnalytics(${logAnalyticsWorkspaceName})'
  galleryName: 'KeyVaultAnalytics'
}
var vmInsights = {
  name: 'VMInsights(${logAnalyticsWorkspaceName})'
  galleryName: 'VMInsights'
}

var environmentName = 'production'
var functionName = 'monitoring and diagnostics'
var costCenterName = 'it'

// resource - log analytics workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
  }
}

// resource - log analytics workspace - diagnostic settings
resource logAnalyticsWorkspaceDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${logAnalyticsWorkspace.name}-diagnostics'
  scope: logAnalyticsWorkspace
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'Audit'
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

// resource - log analytics workspace - solution - container insights
resource solutionsContainerInsights 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: '${containerInsights.name}'
  location: location
  dependsOn: [
    logAnalyticsWorkspace
  ]
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
  plan: {
    name: '${containerInsights}.Name'
    publisher: 'Microsoft'
    product: 'OMSGallery/${containerInsights.galleryName}'
    promotionCode: ''
  }
}

// resource - log analytics workspace - solution - key vault analytics
resource solutionsKeyVaultAnalytics 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: '${keyVaultAnalytics.name}'
  location: location
  dependsOn: [
    logAnalyticsWorkspace
  ]
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
  plan: {
    name: '${keyVaultAnalytics}.Name'
    publisher: 'Microsoft'
    product: 'OMSGallery/${keyVaultAnalytics.galleryName}'
    promotionCode: ''
  }
}

// resource - log analytics workspace - solution - vm insights
resource solutionsVMInsights 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: '${vmInsights.name}'
  location: location
  dependsOn: [
    logAnalyticsWorkspace
  ]
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
  plan: {
    name: '${vmInsights}.Name'
    publisher: 'Microsoft'
    product: 'OMSGallery/${vmInsights.galleryName}'
    promotionCode: ''
  }
}

// outputs
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
