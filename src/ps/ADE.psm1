Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'

# Scoped Variables
# TODO: is there a better place for these, like in the PrivateData?
$modules = @{
    'All'             = 'all'
    'Networking'      = 'networking'
    'AppServices'     = 'apps'
    'VirtualMachines' = 'vms'
}

# These are shared scripts with both public and private scripts
$Shared = @( Get-ChildItem -Path $PSScriptRoot\shared\*.ps1 -ErrorAction SilentlyContinue )

# Note, these are assuming that scripts are in subfolders one layer deep
# TODO: gather all children, regardless of path
$Private = @( Get-ChildItem -Path $PSScriptRoot\private\**\*.ps1 -ErrorAction SilentlyContinue )
$Public = @( Get-ChildItem -Path $PSScriptRoot\public\**\*.ps1 -ErrorAction SilentlyContinue )

Foreach ($import in @($Shared + $Private + $Public)) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

Export-ModuleMember -Function $Shared.Basename
Export-ModuleMember -Function $Public.Basename