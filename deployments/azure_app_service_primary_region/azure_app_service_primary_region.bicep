///////////////////////////////////////////////////////
//
// Azure App Service: Primary Region
//
// This template builds the required resources for the
// ADE App on PaaS in the primary region.
// 
///////////////////////////////////////////////////////

// Parameters
///////////////////////////////////////////////////////

param location string = resourceGroup().location
param environment string = 'brmar'

// Variables
///////////////////////////////////////////////////////
var appServicePlanName = 'plan-ade-${environment}-${location}'
var appServiceAdeApiGateway = 'app-${environment}-${location}-adeapigateway'
var appServiceAdeDataIngestorService = 'app-${environment}-${location}-adedataingestorservice'
var appServiceAdeDataReporterService = 'app-${environment}-${location}-adedatareporterservice'
var appServiceAdeFrontend = 'app-${environment}-${location}-adefrontend'
var appServiceAdeUserService = 'app-${environment}-${location}-adeuserservice'

// Resources
///////////////////////////////////////////////////////

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2020-10-01' = {
  name: appServicePlanName
  location: location
  tags: {
    environment: environment
    module: 'paas'
    solution: 'azure-demo-environment'
  }
  properties: {
    perSiteScaling: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: true
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
  }
  kind: 'linux'
  sku: {
    name: 'P3V3'
    tier: 'Premium'
    size: 'P3v3'
    family: 'P'
    capacity: 1
  }
}
