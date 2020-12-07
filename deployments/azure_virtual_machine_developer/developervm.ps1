# Install Chocolatey Packager
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Silent Install Software Tools
# Install System Tools
# Install Microsoft Edge
choco install microsoft-edge -confirm:$false
# Install .NET Core SDK
choco install dotnetcore-sdk -confirm:$false
# Install PowerShell Core 7
choco install powershell-core -confirm:$false
# Install SQL Server Management Studio
choco install sql-server-management-studio -confirm:$false
# Install Windows Subsystem for Linux
choco install wsl -confirm:$false

# Install Azure Tools
# Install AZ Copy
choco install azcopy -confirm:$false
# Install Azure CLI
choco install azure-cli -confirm:$false
# Install Azure PowerShell
choco install azurepowershell -confirm:$false
# Install Azure Data Studio
choco install azure-data-studio -confirm:$false
# Install Cosmos DB Explorer
choco install cosmosdbexplorer -confirm:$false
# Install Azure Functions Core Tools
choco install azure-functions-core-tools -confirm:$false
# Install Azure Storage Explorer
choco install microsoftazurestorageexplorer -confirm:$false
# Install Service Bus Explorer
choco install servicebusexplorer -confirm:$false

# Install Additional Tools
# Install Docker Desktop
choco install docker-desktop -confirm:$false
# Install Node.js
choco install nodejs-lts -confirm:$false
# Install Postman
choco install postman -confirm:$false
# Install Putty
choco install putty.install -confirm:$false
