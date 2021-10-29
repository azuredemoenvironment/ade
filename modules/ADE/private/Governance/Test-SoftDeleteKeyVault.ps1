function Test-SoftDeleteKeyVault {
    param(
        [string] $KeyVaultName       
    )

    $ListSoftDeletedKVs = az keyvault list-deleted --resource-type vault | ConvertFrom-Json
    if ($ListSoftDeletedKVs.Name -contains $armParameters.keyVaultName) {
        return $true
    }
    
    return $false 
}