function Deploy-AzureVpnGateway {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure VPN Gateway' $armParameters -resourceGroupName $armParameters.networkingResourceGroupName
}