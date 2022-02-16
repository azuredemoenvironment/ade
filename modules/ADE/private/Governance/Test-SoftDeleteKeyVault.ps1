function Test-SoftDeleteKeyVault {
    param(
        [string] $KeyVaultName       
    )

    Write-Status "Listing deleted KeyVault resources"

    try {
        $ListSoftDeletedKVs = az keyvault list-deleted --resource-type vault | ConvertFrom-Json
        if ($ListSoftDeletedKVs.Name -contains $armParameters.keyVaultName) {
            return $true
        }
    }
    catch {
        # do nothing
        Write-Status "Could not find deleted KeyVault resources with name $KeyVaultName"
    }    
    return $false 
}