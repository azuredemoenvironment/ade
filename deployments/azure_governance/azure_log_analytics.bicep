// Parameters
@description('Parameter for the location of resources. Defined in azure_governance.bicep.')
param location string

@description('Parameter for the name of the Data Collection Rule. Defined in azure_governance.bicep.')
param logAnalyticsWorkspaceName string

// Variables
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

// Resource - Log Anlaytics Workspace
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

// Resource - Log Analytics Workspace - Solution - Container Insights
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
    name: '${containerInsights.name}'
    publisher: 'Microsoft'
    product: 'OMSGallery/${containerInsights.galleryName}'
    promotionCode: ''
  }
}

// Resource - Log Analytics Workspace - Solution - Key Vault Analytics
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
    name: '${keyVaultAnalytics.name}'
    publisher: 'Microsoft'
    product: 'OMSGallery/${keyVaultAnalytics.galleryName}'
    promotionCode: ''
  }
}

// Resource - Log Analytics Workspace - Solution - Vm Insights
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
    name: '${vmInsights.name}'
    publisher: 'Microsoft'
    product: 'OMSGallery/${vmInsights.galleryName}'
    promotionCode: ''
  }
}

// Resource - Log Analytics Workspace - Diagnostic Settings
resource logAnalyticsWorkspaceDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: logAnalyticsWorkspace
  name: '${logAnalyticsWorkspace.name}-diagnostics'
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

// Outputs
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
