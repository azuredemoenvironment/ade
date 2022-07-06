function Write-Log {
    param([string] $message)

    Write-Host $message -ForegroundColor Gray | Out-Null
}
