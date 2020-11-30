function Remove-AzurePolicyAssignmentsAndDefinitions {
    param (
        [object] $armParameters
    )

    Write-ScriptSection "Removing Azure Policy Assignments and Definitions"

    # TODO: should these be in the main arm parameters?
    $adeInitiativeAssignment = 'Azure Demo Environment Initiative'
    $azureMonitorforVMsInitiativeAssignment = 'Enable Azure Monitor for VMs'
    $azureMonitorforVMSSInitiativeAssignment = 'Enable Azure Monitor for Virtual Machine Scale Sets'
    $adeInitiativeDefinition = 'Azure Demo Environment Initiative'

    Write-Log "Removing Policy Assignment: $adeInitiativeAssignment"
    az policy assignment delete -n "$adeInitiativeAssignment"
    Confirm-LastExitCode
    
    Write-Log "Removing Policy Assignment: $azureMonitorforVMsInitiativeAssignment"
    az policy assignment delete -n $azureMonitorforVMsInitiativeAssignment
    Confirm-LastExitCode
    
    Write-Log "Removing Policy Assignment: $azureMonitorforVMSSInitiativeAssignment"
    az policy assignment delete -n $azureMonitorforVMSSInitiativeAssignment
    Confirm-LastExitCode
    
    Write-Log "Removing Policy Definition: $adeInitiativeDefinition"
    az policy set-definition delete -n $adeInitiativeDefinition
    Confirm-LastExitCode

    Write-ScriptSection "Removed Azure Policy Assignments and Definitions"
}