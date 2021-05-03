// target scope
targetScope = 'subscription'

// parameters
param defaultPrimaryRegion string
param monitorResourceGroupName string
param identityResourceGroupName string
param networkingResourceGroupName string
param adeAppSqlResourceGroupName string
param inspectorGadgetResourceGroupName string
param jumpboxResourceGroupName string
param nTierResourceGroupName string
param vmssResourceGroupName string
param w10clientResourceGroupName string

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
