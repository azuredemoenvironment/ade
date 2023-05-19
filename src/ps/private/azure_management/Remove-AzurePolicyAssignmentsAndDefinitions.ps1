function Remove-AzurePolicyAssignmentsAndDefinitions {
    param (
        [object] $armParameters
    )

    Write-ScriptSection "Removing Azure Policy Assignments and Definitions"

    # TODO: should these be in the main arm parameters?
    $adeInitiativeDefinition = $armParameters.adeInitiativeDefinition

    Write-Log "Removing Policy Assignment: $adeInitiativeDefinition"
    az policy assignment delete -n "$adeInitiativeDefinition"
    Confirm-LastExitCode

    Write-ScriptSection "Removed Azure Policy Assignments and Definitions"
}