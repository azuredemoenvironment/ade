function Restore-SoftDeleteKeyVault {
    param(
        [string] $KeyvaultName       
    )
    Write-Log "Restoring Soft-Delete KeyVault by running: az keyvault recover -n $KeyvaultName | Out-Null" 
    az keyvault recover -n $KeyvaultName | Out-Null
    Confirm-LastExitCode
}