function Deploy-AppConfig {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure App Config' $armParameters -resourceGroupName $armParameters.keyVaultResourceGroupName -bicep
}