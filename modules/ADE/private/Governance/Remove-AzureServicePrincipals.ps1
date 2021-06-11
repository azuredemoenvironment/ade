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

    $githubActionsSPNName = $armParameters.githubActionsSPNName
    if (Confirm-AzureResourceExists 'service principal' $githubActionsSPNName) {
        az ad sp delete --id http://$githubActionsSPNName
        Confirm-LastExitCode
    }

    $containerRegistrySPNName = $armParameters.containerRegistrySPNName
    if (Confirm-AzureResourceExists 'service principal' $containerRegistrySPNName) {
        az ad sp delete --id http://$containerRegistrySPNName
        Confirm-LastExitCode
    }

    Write-ScriptSection "Finished Removing Azure Service Principals"
}