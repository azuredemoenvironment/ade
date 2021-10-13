function Test-SoftDeleteKeyVault {
    param(
        [string] $KeyvaultName       
    )

    $ListSoftDeletedKVs = az keyvault list-deleted --resource-type vault | ConvertFrom-Json
    If ($ListSoftDeletedKVs.Name -contains $armParameters.keyVaultName){
        return $true
    }
    else {
        return $false 
    }
}