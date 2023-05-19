function Remove-AzureActivityLogDiagnostics {
    param (
        [object] $armParameters
    )

    Write-ScriptSection "Removing Azure Activity Log Diagnostics"
    
    $activityLogDiagnosticsName = $armParameters.activityLogDiagnosticsName
    az monitor diagnostic-settings subscription delete -n $activityLogDiagnosticsName -y
    Confirm-LastExitCode

    Write-ScriptSection "Finished Removing Azure Activity Log Diagnostics"
}