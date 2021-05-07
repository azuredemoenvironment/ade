function Write-Header {
    param([string] $message)

    Write-Host "************************************************************************" -ForegroundColor Cyan | Out-Null
    Write-Host $message -ForegroundColor Yellow | Out-Null
    Write-Host "************************************************************************" -ForegroundColor Cyan | Out-Null
    Write-Host "" | Out-Null
}

function Login {
    Invoke-Expression "& `"/opt/ade/login.ps1`""
}

function Deploy {
    Invoke-Expression "& `"/opt/ade/ade.ps1`" -deploy $args"
}

function Remove {
    Invoke-Expression "& `"/opt/ade/ade.ps1`" -remove $args"
}

function Deallocate {
    Invoke-Expression "& `"/opt/ade/ade.ps1`" -deallocate $args"
}

function Allocate {
    Invoke-Expression "& `"/opt/ade/ade.ps1`" -allocate $args"
}

function Prompt {
    "ADE > "
}

Write-Header "Welcome to the Azure Demo Environment"

/opt/ade/login.ps1

Write-Header 'Done! Run "deploy" to start deploying the Azure Demo Environment!'