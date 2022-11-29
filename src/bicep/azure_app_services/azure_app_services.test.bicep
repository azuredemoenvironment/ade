// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'


module app_service_test 'azure_app_services.bicep' = {
  name: 'app_service_test'
  params: {
    adminUserName: 'AzureAdmin'
    aliasRegion: 'eus'
    azureRegion: 'EastUS'  
    location: 'EastUS' 
  }
}
