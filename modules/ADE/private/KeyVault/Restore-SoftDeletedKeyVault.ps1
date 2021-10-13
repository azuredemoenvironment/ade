function Restore-SoftDeleteKeyvault {
    param(
        [string] $KeyvaultName       
    )

    az keyvault recover -n $KeyvaultName | Out-Null
    Confirm-LastExitCode
}