// target scope
targetScope = 'subscription'

// parameters
param defaultPrimaryRegion string
param adeAppSqlResourceGroupName string
param inspectorGadgetResourceGroupName string

// resource group - adeAppSql
resource adeAppSqlResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: adeAppSqlResourceGroupName
  location: defaultPrimaryRegion
}

// resource group - inspectorGadgetSql
resource inspectorGadgetSqlResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: inspectorGadgetResourceGroupName
  location: defaultPrimaryRegion
}
