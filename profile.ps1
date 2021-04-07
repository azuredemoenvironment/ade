function Write-Header {
    param([string] $message)

    Write-Host "************************************************************************" -ForegroundColor Cyan | Out-Null
    Write-Host $message -ForegroundColor Yellow | Out-Null
    Write-Host "************************************************************************" -ForegroundColor Cyan | Out-Null
    Write-Host "" | Out-Null
}

function Deploy {
    /opt/ade/ade.ps1 -deploy
}

function Remove {
    /opt/ade/ade.ps1 -remove
}

function Deallocate {
    /opt/ade/ade.ps1 -deallocate
}

function allocate {
    /opt/ade/ade.ps1 -allocate
}

function Prompt {
    "ADE > "
}

Write-Header "Welcome to the Azure Demo Environment"

/opt/ade/login.ps1

Write-Header 'Done! Run "deploy" to start deploying the Azure Demo Environment!'