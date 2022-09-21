function Write-Header {
    param([string] $message)

    Write-Host "************************************************************************" -ForegroundColor Cyan | Out-Null
    Write-Host $message -ForegroundColor Yellow | Out-Null
    Write-Host "************************************************************************" -ForegroundColor Cyan | Out-Null
    Write-Host "" | Out-Null
}

function FullLogin {
    Invoke-Expression "& `"/opt/ade/login.ps1`""
}

function Login {
    Invoke-Expression "& `"/opt/ade/login.ps1`" -loginOnly"
}

function ChangeRegion {
    Invoke-Expression "& `"/opt/ade/login.ps1`" -regionOnly"
}

function ChangeSubscription {
    Invoke-Expression "& `"/opt/ade/login.ps1`" -subscriptionOnly"
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

FullLogin

Write-Header 'Done! Run "deploy" to start deploying the Azure Demo Environment!'