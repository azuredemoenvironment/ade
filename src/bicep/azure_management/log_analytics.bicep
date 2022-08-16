// Parameters
//////////////////////////////////////////////////
@description('The location for all resources.')
param location string

@description('The name of the Log Analytics Workspace')
param logAnalyticsWorkspaceName string

@description('The array of properties for the Log Analytics Workspace Solutions.')
param logAnalyticsWorkspaceSolutions array

@description('The list of Resource tags')
param tags object

// Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: tags
  properties: {
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
  }
}

// Resource - Log Analytics Workspace Solution
//////////////////////////////////////////////////
resource logAnalyticsWorkspaceSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [for (logAnalyticsWorkspaceSolution, i) in logAnalyticsWorkspaceSolutions: {
  name: logAnalyticsWorkspaceSolution.name
  location: location
  tags: tags
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
  plan: {
    name: logAnalyticsWorkspaceSolution.name
    publisher: 'Microsoft'
    product: 'OMSGallery/${logAnalyticsWorkspaceSolution.galleryName}'
    promotionCode: ''
  }
}]

// Resource - Log Analytics Workspace - Diagnostic Settings
//////////////////////////////////////////////////
resource logAnalyticsWorkspaceDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: logAnalyticsWorkspace
  name: '${logAnalyticsWorkspace.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'Audit'
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
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
