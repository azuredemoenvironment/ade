function Deploy-AzureSecurity {
    param(
        [object] $armParameters
    )

    # Deploy Azure Security
    ##################################################
    Write-ScriptSection "Initializing Security Deployment"

    # Parameters
    ##################################################
    $azureRegion = $armParameters.azureRegion
    $resourceGroupName = $armParameters.securityResourceGroupName
    $keyVaultName = $armParameters.keyVaultName

    # TODO: There's a scenario when debugging just this module that the keyVaultResourceID property doesn't exist. This wouldn't happen in a normal run.
    $keyVaultResourceIdPropertyExists = $false
    try {
        $keyVaultResourceIdPropertyExists = [bool]($armParameters.PSobject.Properties.name -match 'keyVaultResourceID')    
    }
    catch {
        # do nothing
        Write-Status "Could not find keyVaultResourceID on armParameters"
    }

    if ((-not $keyVaultResourceIdPropertyExists -or (!$armParameters.keyVaultResourceID)) -and (Test-SoftDeleteKeyVault -KeyVaultName $armParameters.keyVaultName)) {
        Restore-SoftDeleteKeyVault -KeyVaultResourceGroupName $armParameters.securityResourceGroupName -KeyVaultName $armParameters.keyVaultName
    }

    # Create the Azure Security Resource Group
    az group create -n $resourceGroupName -l $azureRegion

    # Deploy the Azure Security Bicep Template at the Resource Group Scope.
    ##################################################
    Deploy-ArmTemplate 'Azure Security' $armParameters $resourceGroupName  -bicep

    Write-Status "Finished Azure Security Deployment"

    # Configure Azure KeyVault
    ##################################################
    Write-Status "Configuring Azure Key Vault $keyVaultName"

    # Set the Azure KeyVault resource id for future deployments.
    Set-AzureKeyVaultResourceId $armParameters

    Write-Status "Finished Configuring Azure Key Vault $keyVaultName"
}
