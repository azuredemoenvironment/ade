function Deploy-AzureFirewall {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Firewall' $armParameters -resourceGroupName $armParameters.networkingResourceGroupName
}