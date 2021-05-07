function Remove-AzureActivityLogDiagnostics {
    param (
        [object] $armParameters
    )

    Write-ScriptSection "Removing Azure Activity Log Diagnostics"
    
    # TODO: should this be in the main arm parameters?
    $activityLogDiagnosticsName = $armParameters.activityLogDiagnosticsName
    az monitor diagnostic-settings subscription delete -n $activityLogDiagnosticsName -y
    Confirm-LastExitCode

    Write-ScriptSection "Finished Removing Azure Activity Log Diagnostics"
}