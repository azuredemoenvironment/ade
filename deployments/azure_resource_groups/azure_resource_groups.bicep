// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'

// Parameters
//////////////////////////////////////////////////
param azureRegion string

// Global Variables
//////////////////////////////////////////////////
param monitorResourceGroupName string
param appConfigResourceGroupName string
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

// Resource Group - Monitor
//////////////////////////////////////////////////
resource monitorResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: monitorResourceGroupName
  location: azureRegion
}

// Resource Group - App Config
//////////////////////////////////////////////////
resource appConfigResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: appConfigResourceGroupName
  location: azureRegion
}

// Resource Group - Identity
//////////////////////////////////////////////////
resource identityResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: identityResourceGroupName
  location: azureRegion
}

// Resource Group - Key Vault
//////////////////////////////////////////////////
resource keyVaultResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: keyVaultResourceGroupName
  location: azureRegion
}

// Resource Group - Networking
//////////////////////////////////////////////////
resource networkingResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: networkingResourceGroupName
  location: azureRegion
}

// Resource Group - Adeappsql
//////////////////////////////////////////////////
resource adeAppSqlResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: adeAppSqlResourceGroupName
  location: azureRegion
}

// Resource Group - Inspectorgadget
//////////////////////////////////////////////////
resource inspectorGadgetResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: inspectorGadgetResourceGroupName
  location: azureRegion
}

// Resource Group - Jumpbox
//////////////////////////////////////////////////
resource jumpboxResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: jumpboxResourceGroupName
  location: azureRegion
}

// Resource Group - Ntier
//////////////////////////////////////////////////
resource nTierResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: nTierResourceGroupName
  location: azureRegion
}

// Resource Group - Vmss
//////////////////////////////////////////////////
resource vmssResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: vmssResourceGroupName
  location: azureRegion
}

// Resource Group - W10client
//////////////////////////////////////////////////
resource w10clientResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: w10clientResourceGroupName
  location: azureRegion
}

// Resource Group - Azure Container Registry
//////////////////////////////////////////////////
resource containerRegistryResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: containerRegistryResourceGroupName
  location: azureRegion
}

// Resource Group - Adeapploadtesting
//////////////////////////////////////////////////
resource adeAppLoadTestingResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: adeAppLoadTestingResourceGroupName
  location: azureRegion
}

// Resource Group - App Service Plan
//////////////////////////////////////////////////
resource appServicePlanResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: appServicePlanResourceGroupName
  location: azureRegion
}

// Resource Group - Adeappapp
//////////////////////////////////////////////////
resource adeAppAppServiceResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: adeAppAppServicesResourceGroupName
  location: azureRegion
}
