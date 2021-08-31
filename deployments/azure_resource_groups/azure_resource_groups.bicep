// target scope
targetScope = 'subscription'

// parameters
param defaultPrimaryRegion string
param monitorResourceGroupName string
param identityResourceGroupName string
param keyVaultResourceGroupName string
param networkingResourceGroupName string
param adeAppSqlResourceGroupName string
param inspectorGadgetResourceGroupName string
param jumpboxResourceGroupName string
param nTierResourceGroupName string
param vmssResourceGroupName string
param w10clientResourceGroupName string
param containerRegistryResourceGroupName string
param adeAppLoadTestingResourceGroupName string
param appServicePlanResourceGroupName string
param adeAppAppServicesResourceGroupName string

// resource group - monitor
resource monitorResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: monitorResourceGroupName
  location: defaultPrimaryRegion
}

// resource group - identity
resource identityResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: identityResourceGroupName
  location: defaultPrimaryRegion
}

// resource group - key vault
resource keyVaultResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: keyVaultResourceGroupName
  location: defaultPrimaryRegion
}

// resource group - networking
resource networkingResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: networkingResourceGroupName
  location: defaultPrimaryRegion
}

// resource group - adeAppSql
resource adeAppSqlResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: adeAppSqlResourceGroupName
  location: defaultPrimaryRegion
}

// resource group - inspectorGadget
resource inspectorGadgetResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: inspectorGadgetResourceGroupName
  location: defaultPrimaryRegion
}

// resource group - jumpbox
resource jumpboxResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: jumpboxResourceGroupName
  location: defaultPrimaryRegion
}

// resource group - nTier
resource nTierResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: nTierResourceGroupName
  location: defaultPrimaryRegion
}

// resource group - vmss
resource vmssResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: vmssResourceGroupName
  location: defaultPrimaryRegion
}

// resource group - w10client
resource w10clientResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: w10clientResourceGroupName
  location: defaultPrimaryRegion
}

// resource group - azure container registry
resource containerRegistryResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: containerRegistryResourceGroupName
  location: defaultPrimaryRegion
}

// resource group - adeAppLoadTesting
resource adeAppLoadTestingResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: adeAppLoadTestingResourceGroupName
  location: defaultPrimaryRegion
}

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
