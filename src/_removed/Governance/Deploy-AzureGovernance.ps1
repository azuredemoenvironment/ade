function Deploy-AzureGovernance {
    param(
        [object] $armParameters
    )

    # Deploy Azure Governance
    ##################################################
    Write-ScriptSection "Initializing Azure Governance Deployment"

    # Parameters
    ##################################################
    $keyVaultKeyName = $armParameters.keyVaultKeyName
    $keyVaultName = $armParameters.keyVaultName

    # there's a scenario when debugging just this module that the keyVaultResourceID property
    # doesn't exist; this wouldn't happen in a normal run
    $keyVaultResourceIdPropertyExists = $false
    try {
        $keyVaultResourceIdPropertyExists = [bool]($armParameters.PSobject.Properties.name -match 'keyVaultResourceID')    
    }
    catch {
        # do nothing
        Write-Status "Could not find keyVaultResourceID on armParameters"
    }

    if ((-not $keyVaultResourceIdPropertyExists -or (!$armParameters.keyVaultResourceID)) -and (Test-SoftDeleteKeyVault -KeyVaultName $armParameters.keyVaultName)) {
        Restore-SoftDeleteKeyVault -KeyVaultResourceGroupName $armParameters.keyVaultResourceGroupName -KeyVaultName $armParameters.keyVaultName
    }

    # Deploy the Azure Governance Bicep template at the subscription scope.
    ##################################################
    Deploy-ArmTemplate 'Azure Governance' $armParameters -resourceLevel 'sub' -bicep

    Write-Status "Finished Azure Governance Deployment"

    # Configure Azure KeyVault
    ##################################################
    Write-Status "Configuring Azure Key Vault $keyVaultName"
    
    # Set the Azure KeyVault resource id for future deployments.
    Set-AzureKeyVaultResourceId $armParameters

    Write-Status "Finished Configuring Azure Key Vault $keyVaultName"
}
