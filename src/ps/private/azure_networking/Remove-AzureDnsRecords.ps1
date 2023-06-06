function Remove-AzureDnsRecords {
    param (
        [object] $armParameters
    )

    Write-ScriptSection "Removing Azure Dns A Records "

    $dnsARecordsToRemove = @(
        ade-apigateway-vm
        ade-apigateway-vmss
        ade-frontend-vm
        ade-frontend-vmss
    )

    $dnsARecordsToRemove | ForEach-Object {
        $dnsARecordExists = Confirm-AzureResourceExists 'dns a record' $_
        if (-not $dnsARecordExists) {
            Write-Log "The Dns A Record $_ does not exist; skipping."
            return
        }

        Write-Log "Removing $_ Dns A Record"

        az network dns record-set a delete -n $_ -y
        Confirm-LastExitCode

        Write-Log "Removed $_ Dns A Record"
    }

    Write-ScriptSection "Removing Azure Dns Cname Records "

    $dnsCnameRecordsToRemove = @(
        ade-apigateway-app
        ade-dataingestorservice-app
        ade-datareporterservice-app
        ade-eventingestorservice-app
        ade-frontend-app
        ade-userservice-app
        inspectorgadget
    )

    $dnsCnameRecordsToRemove | ForEach-Object {
        $dnsCnameRecordExists = Confirm-AzureResourceExists 'dns cname record' $_
        if (-not $dnsCnameRecordExists) {
            Write-Log "The Dns Cname Record $_ does not exist; skipping."
            return
        }

        Write-Log "Removing $_ Dns Cname Record"

        az network dns record-set cname delete -n $_ -y
        Confirm-LastExitCode

        Write-Log "Removed $_ Dns Cname Record"
    }

    Write-ScriptSection "Removing Azure Dns Txt Records "

    $dnsTxtRecordsToRemove = @(
        _dnsauth.ade-apigateway-app
        _dnsauth.ade-frontend-app
        _dnsauth.inspectorgadget
        asuid.ade-apigateway-app
        asuid.ade-dataingestorservice-app
        asuid.ade-datareporterservice-app
        asuid.ade-eventingestorservice-app
        asuid.ade-frontend-app
        asuid.ade-userservice-app
        asuid.inspectorgadget
    )

    $dnsTxtRecordsToRemove | ForEach-Object {
        $dnsTxtRecordExists = Confirm-AzureResourceExists 'dns txt record' $_
        if (-not $dnsTxtRecordExists) {
            Write-Log "The Dns Txt Record $_ does not exist; skipping."
            return
        }

        Write-Log "Removing $_ Dns Txt Record"

        az network dns record-set txt delete -n $_ -y
        Confirm-LastExitCode

        Write-Log "Removed $_ Dns Txt Record"
    }
}

# TODO: remove these entries before merging to main

# # A Records
# az network dns record-set a delete -g rg-joshuawaddell.cloud -z joshuawaddell.cloud -n ade-apigateway-vm
# az network dns record-set a delete -g rg-joshuawaddell.cloud -z joshuawaddell.cloud -n ade-apigateway-vmss
# az network dns record-set a delete -g rg-joshuawaddell.cloud -z joshuawaddell.cloud -n ade-frontend-vm
# az network dns record-set a delete -g rg-joshuawaddell.cloud -z joshuawaddell.cloud -n ade-frontend-vmss

# # CNAME Records
# az network dns record-set cname delete -g rg-joshuawaddell.cloud -z joshuawaddell.cloud -n ade-apigateway-app
# az network dns record-set cname delete -g rg-joshuawaddell.cloud -z joshuawaddell.cloud -n ade-dataingestorservice-app
# az network dns record-set cname delete -g rg-joshuawaddell.cloud -z joshuawaddell.cloud -n ade-datareporterservice-app
# az network dns record-set cname delete -g rg-joshuawaddell.cloud -z joshuawaddell.cloud -n ade-eventingestorservice-app
# az network dns record-set cname delete -g rg-joshuawaddell.cloud -z joshuawaddell.cloud -n ade-userservice-app
# az network dns record-set cname delete -g rg-joshuawaddell.cloud -z joshuawaddell.cloud -n apigateway-app
# az network dns record-set cname delete -g rg-joshuawaddell.cloud -z joshuawaddell.cloud -n inspectorgadget

# # TXT Records
# az network dns record-set txt delete -g rg-joshuawaddell.cloud -z joshuawaddell.cloud -n asuid.ade-apigateway-app
# az network dns record-set txt delete -g rg-joshuawaddell.cloud -z joshuawaddell.cloud -n asuid.ade-dataingestorservice-app
# az network dns record-set txt delete -g rg-joshuawaddell.cloud -z joshuawaddell.cloud -n asuid.ade-datareporterservice-app
# az network dns record-set txt delete -g rg-joshuawaddell.cloud -z joshuawaddell.cloud -n asuid.ade-eventingestorservice-app
# az network dns record-set txt delete -g rg-joshuawaddell.cloud -z joshuawaddell.cloud -n asuid.ade-frontend-app
# az network dns record-set txt delete -g rg-joshuawaddell.cloud -z joshuawaddell.cloud -n asuid.ade-userservice-app
# az network dns record-set txt delete -g rg-joshuawaddell.cloud -z joshuawaddell.cloud -n _dnsauth.ade-apigateway-app
# az network dns record-set txt delete -g rg-joshuawaddell.cloud -z joshuawaddell.cloud -n _dnsauth.ade-frontend-app
# az network dns record-set txt delete -g rg-joshuawaddell.cloud -z joshuawaddell.cloud -n _dnsauth.inspectorgadget
# az network dns record-set txt delete -g rg-joshuawaddell.cloud -z joshuawaddell.cloud -n asuid.inspectorgadget