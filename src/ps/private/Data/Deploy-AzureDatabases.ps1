function Deploy-AzureDatabases {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Databases' $armParameters -resourceLevel 'sub' -bicep
}