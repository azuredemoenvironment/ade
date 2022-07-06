function Write-Status {
    param([string] $message)

    Write-Host $message -ForegroundColor Cyan | Out-Null
}