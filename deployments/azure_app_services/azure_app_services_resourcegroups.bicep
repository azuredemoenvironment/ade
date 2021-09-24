// target scope
targetScope = 'subscription'

// parameters
param azureRegion string
param appServicePlanResourceGroupName string
param adeAppAppServicesResourceGroupName string
param inspectorGadgetResourceGroupName string

// resource group - app service plan
resource appServicePlanResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: appServicePlanResourceGroupName
  location: azureRegion
}

// resource group - adeAppApp
resource adeAppAppServiceResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: adeAppAppServicesResourceGroupName
  location: azureRegion
}

// resource group - inspectorGadget
resource inspectorGadgetResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: inspectorGadgetResourceGroupName
  location: azureRegion
}
