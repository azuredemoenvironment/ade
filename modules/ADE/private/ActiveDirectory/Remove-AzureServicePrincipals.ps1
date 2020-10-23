function Remove-AzureServicePrincipals {
    param (
        [object] $armParameters
    )

    Write-ScriptSection "Removing Azure Service Principals"

    $restAPISPNName = $armParameters.restAPISPNName
    if (Confirm-AzureResourceExists 'service principal' $restAPISPNName) {
        az ad sp delete --id http://$restAPISPNName
        Confirm-LastExitCode
    }

    $crSPNName = $armParameters.crSPNName
    if (Confirm-AzureResourceExists 'service principal' $crSPNName) {
        az ad sp delete --id http://$crSPNName
        Confirm-LastExitCode
    }

    Write-ScriptSection "Finished Removing Azure Service Principals"
}