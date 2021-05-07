// target scope
targetScope = 'subscription'

// parameters
param defaultPrimaryRegion string
param appServicePlanResourceGroupName string
param adeAppAppServicesResourceGroupName string
param inspectorGadgetResourceGroupName string

// resource group - app service plan
resource appServicePlanResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: appServicePlanResourceGroupName
  location: defaultPrimaryRegion
}

// resource group - adeAppApp
resource adeAppAppServiceResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: adeAppAppServicesResourceGroupName
  location: defaultPrimaryRegion
}

// resource group - inspectorGadget
resource inspectorGadgetResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: inspectorGadgetResourceGroupName
  location: defaultPrimaryRegion
}
