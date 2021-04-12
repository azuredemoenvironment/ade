function Deploy-StorageFirewallRules {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Starting Storage Firewall Rules Deployment"

    $monitorResourceGroupName = $armParameters.monitorResourceGroupName
    $vmDiagnosticsStorageAccountName = $armParameters.vmDiagnosticsStorageAccountName
    $networkingResourceGroup = $armParameters.networkingResourceGroupName
    $virtualNetwork001Name = $armParameters.virtualNetwork001Name
    $virtualNetwork002Name = $armParameters.virtualNetwork002Name
    $sourceAddressPrefix = $armParameters.sourceAddressPrefix
        
    Write-Log 'Gathering Subnet IDs'
    $managementSubnetID = az network vnet subnet show -g $networkingResourceGroup -n 'management' --vnet-name $virtualNetwork001Name --query id
    Confirm-LastExitCode

    $nTierWebSubnetID = az network vnet subnet show -g $networkingResourceGroup -n 'nTierWeb' --vnet-name $virtualNetwork002Name --query id
    Confirm-LastExitCode

    $nTierAppSubnetID = az network vnet subnet show -g $networkingResourceGroup -n 'nTierApp' --vnet-name $virtualNetwork002Name --query id
    Confirm-LastExitCode

    $nTierDBSubnetID = az network vnet subnet show -g $networkingResourceGroup -n 'nTierDB' --vnet-name $virtualNetwork002Name --query id
    Confirm-LastExitCode
        
    $vmssSubnetID = az network vnet subnet show -g $networkingResourceGroup -n 'vmss' --vnet-name $virtualNetwork002Name --query id
    Confirm-LastExitCode

    $clientServicesSubnetID = az network vnet subnet show -g $networkingResourceGroup -n 'clientServices' --vnet-name $virtualNetwork002Name --query id
    Confirm-LastExitCode

    Write-Log "Setting Storage Firewall Rules for Subnets"

    az storage account network-rule add -g $monitorResourceGroupName --account-name $vmDiagnosticsStorageAccountName --subnet $managementSubnetID --action allow
    Confirm-LastExitCode

    az storage account network-rule add -g $monitorResourceGroupName --account-name $vmDiagnosticsStorageAccountName --subnet $nTierWebSubnetID --action allow
    Confirm-LastExitCode

    az storage account network-rule add -g $monitorResourceGroupName --account-name $vmDiagnosticsStorageAccountName --subnet $nTierWebSubnetID --action allow
    Confirm-LastExitCode

    az storage account network-rule add -g $monitorResourceGroupName --account-name $vmDiagnosticsStorageAccountName --subnet $nTierDBSubnetID --action allow
    Confirm-LastExitCode

    az storage account network-rule add -g $monitorResourceGroupName --account-name $vmDiagnosticsStorageAccountName --subnet $vmssSubnetID --action allow
    Confirm-LastExitCode

    az storage account network-rule add -g $monitorResourceGroupName --account-name $vmDiagnosticsStorageAccountName --subnet $clientServicesSubnetID --action allow
    Confirm-LastExitCode

    Write-Log "Finished Setting Storage Firewall Rules"
}