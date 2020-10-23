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

    az policy assignment delete -n $adeInitiativeAssignment
    Confirm-LastExitCode
    
    az policy assignment delete -n $azureMonitorforVMsInitiativeAssignment
    Confirm-LastExitCode
    
    az policy assignment delete -n $azureMonitorforVMSSInitiativeAssignment
    Confirm-LastExitCode
    
    az policy set-definition delete -n $adeInitiativeDefinition
    Confirm-LastExitCode

    Write-ScriptSection "Removing Azure Policy Assignments and Definitions"
}