function Write-Log {
    param([string] $message)

    Write-Host $message -ForegroundColor DarkGray | Out-Null
}
