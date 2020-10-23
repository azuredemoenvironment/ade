function Deploy-StorageFirewallRules {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Starting Storage Firewall Rules Deployment"

    $vmDiagnosticsResourceGroup = $armParameters.storageResourceGroupName
    $vmDiagnosticsStorageAccountName = $armParameters.vmDiagnosticsStorageAccountName
    $networkingResourceGroup = $armParameters.networkingResourceGroupName
    $virtualNetwork01Name = $armParameters.virtualNetwork01Name
    $virtualNetwork02Name = $armParameters.virtualNetwork02Name
    $sourceAddressPrefix = $armParameters.sourceAddressPrefix
        
    Write-Log 'Gathering Subnet IDs'
    $managementSubnetID = az network vnet subnet show -g $networkingResourceGroup -n 'management' --vnet-name $virtualNetwork01Name --query id
    Confirm-LastExitCode

    $directoryServicesSubnetID = az network vnet subnet show -g $networkingResourceGroup -n 'directoryServices' --vnet-name $virtualNetwork01Name --query id
    Confirm-LastExitCode

    $developerSubnetID = az network vnet subnet show -g $networkingResourceGroup -n 'developer' --vnet-name $virtualNetwork02Name --query id
    Confirm-LastExitCode

    $nTierWebSubnetID = az network vnet subnet show -g $networkingResourceGroup -n 'ntierWeb' --vnet-name $virtualNetwork02Name --query id
    Confirm-LastExitCode

    $nTierDBSubnetID = az network vnet subnet show -g $networkingResourceGroup -n 'ntierDB' --vnet-name $virtualNetwork02Name --query id
    Confirm-LastExitCode
        
    $vmssSubnetID = az network vnet subnet show -g $networkingResourceGroup -n 'vmss' --vnet-name $virtualNetwork02Name --query id
    Confirm-LastExitCode

    $clientServicesSubnetID = az network vnet subnet show -g $networkingResourceGroup -n 'clientServices' --vnet-name $virtualNetwork02Name --query id
    Confirm-LastExitCode

    Write-Log 'Setting Storage Firewall Default Action'

    az storage account update -g $vmDiagnosticsResourceGroup -n $vmDiagnosticsStorageAccountName --default-action Deny
    Confirm-LastExitCode

    Write-Log "Setting Storage Firewall Rule for Source Address $sourceAddressPrefix"

    az storage account network-rule add -g $vmDiagnosticsResourceGroup --account-name $vmDiagnosticsStorageAccountName --ip-address $sourceAddressPrefix
    Confirm-LastExitCode

    Write-Log "Setting Storage Firewall Rules for Subnets"

    az storage account network-rule add -g $vmDiagnosticsResourceGroup --account-name $vmDiagnosticsStorageAccountName --subnet $managementSubnetID --action allow
    Confirm-LastExitCode

    az storage account network-rule add -g $vmDiagnosticsResourceGroup --account-name $vmDiagnosticsStorageAccountName --subnet $directoryServicesSubnetID --action allow
    Confirm-LastExitCode

    az storage account network-rule add -g $vmDiagnosticsResourceGroup --account-name $vmDiagnosticsStorageAccountName --subnet $nTierWebSubnetID --action allow
    Confirm-LastExitCode

    az storage account network-rule add -g $vmDiagnosticsResourceGroup --account-name $vmDiagnosticsStorageAccountName --subnet $nTierDBSubnetID --action allow
    Confirm-LastExitCode

    az storage account network-rule add -g $vmDiagnosticsResourceGroup --account-name $vmDiagnosticsStorageAccountName --subnet $vmssSubnetID --action allow
    Confirm-LastExitCode

    az storage account network-rule add -g $vmDiagnosticsResourceGroup --account-name $vmDiagnosticsStorageAccountName --subnet $developerSubnetID --action allow
    Confirm-LastExitCode

    az storage account network-rule add -g $vmDiagnosticsResourceGroup --account-name $vmDiagnosticsStorageAccountName --subnet $clientServicesSubnetID --action allow
    Confirm-LastExitCode

    Write-Log "Finished Setting Storage Firewall Rules"
}