function Confirm-ModuleIsValid {
    param(
        [string] $module
    )

    $modules.GetEnumerator() | ForEach-Object {
        # Check if the module specific equals the value of one of our modules
        if ($_.Value -eq $module) {
            return $true
        }
    }

    return $false
}