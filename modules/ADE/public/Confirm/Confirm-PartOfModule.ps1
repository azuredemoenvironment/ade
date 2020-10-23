function Confirm-PartOfModule {
    param(
        [string] $module,
        [array] $acceptableModules
    )

    # if this is supposed to run for all modules, short circuit and return
    # NOTE: there may come a day that this is not true, for now it is
    if ($module -eq $modules.All) {
        return $true
    }

    $acceptableModules | ForEach-Object {
        if ($module -eq $_) {
            return $true
        }
    }

    return $false
}