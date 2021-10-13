function Test-SoftDeleteKeyVault {
    param(
        [string] $KeyVaultName       
    )

    $ListSoftDeletedKVs = az keyvault list-deleted --resource-type vault | ConvertFrom-Json
    If ($ListSoftDeletedKVs.Name -contains $armParameters.keyVaultName){
        return $true
    }
    else {
        return $false 
    }
}