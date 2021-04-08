function Deploy-AzureStorageAccountVmDiagnostics {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Storage Account VM Diagnostics' $armParameters -resourceGroupName $armParameters.storageResourceGroupName
}