function Deploy-AzurePrivateDns {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Private DNS' $armParameters -resourceGroupName $armParameters.privateDnsZoneResourceGroupName -noWait
}