# Azure Demo Environment

The Azure Demo Environment (ADE) is designed to deploy a solution to your Azure
Subscription demonstrating many of the Azure service offerings. While not every
possible Azure service is deployed, the purpose of the ADE is to showcase
common, but often more complex, scenarios within Azure, and to be an example to
work from when designing your own solutions.

## Requirements

To use the ADE, the following prerequisites are required. Note that some are
software installations, while others require services to be setup before
starting an ADE deployment.

- [PowerShell Core](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
  - [AZ AKS Preview Extension](https://docs.microsoft.com/en-us/azure/aks/start-stop-cluster) -
    `az extension add --name aks-preview` or
    `az extension update --name aks-preview` from a terminal
  - [AZ AKS StartStopPreview feature](https://docs.microsoft.com/en-us/azure/aks/start-stop-cluster#register-the-startstoppreview-preview-feature) -
    `az feature register --namespace "Microsoft.ContainerService" --name "StartStopPreview"`
    from a terminal, followed by
    `az provider register --namespace Microsoft.ContainerService` in a terminal
    after registration has finished, to enable new start and stop functionality
    of AKS in your Azure subscription
  - [az aks kubectl](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az_aks_install_cli) -
    `az aks install-cli` from a terminal
- [Azure PowerShell Cmdlets](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps)
  (may require elevated permissions):
  `Install-Module -Name Az -AllowClobber -Scope CurrentUser`
- PowerShell needs to allow scripts. Run this in a PS command:
  `set-executionpolicy -executionpolicy unrestricted`
- [Docker](https://docs.docker.com/get-docker/). Ensure that Docker is **Running**. (Restart required after installation.)
- A Domain Name Ready to Point at Azure DNS; **note:** this should be a domain
  **not used** for anything else, as a DNS zone will be created and maintained
  for you within Azure DNS
- A PFX wildcard certificate stored at `data/wildcard.pfx` for the domain name
  to be used with Azure DNS

## Using the PowerShell Script to Automatically Build the Environment

A PowerShell script is provided to make use of the ARM templates in the
solution. There are two methods of using the script, as a pipeline-friendly CLI
script or as a CLI-based wizard.

Open a terminal or command prompt and navigate to the root of this solution.
You'll first want to make sure you are logged into the `az` CLI. If you haven't
already, run the following command:

`az login`

After you've logged in, you'll want to select the subscription you want to
deploy ADE into. Get a list of subscriptions with the following command:

`az account list --output table`

You can then set the subscription you'd like to use with the following command:

`az account set --subscription "The Subscription Name"`

Next, build a command using the set of options presented below based on the path
you'd like to take.

A sample of running the PowerShell script from a single CLI command:

`./ade.ps1 -deploy -alias 'abcdef' -email 'abcdef@website.com' -rootDomainName "website.com" -resourceUserName 'abcdef' -resourcePassword 'SampleP@ssword123!' -certificatePassword 'SampleP@ssword123!' -localNetworkRange '192.168.0.0/24' -skipConfirmation -overwriteParameterFiles`

To run as a wizard, you can just execute the script without any parameters:

`./ade.ps1 -deploy`

### Parameters for Both Pipeline and Wizard CLI Commands

Required:

- `-alias [string]`: an alias you would like to use to make the generated
  resources unique globally. This could be your initials or an organization
  alias.
- `-rootDomainName`: the domain name you'd like to use with Azure DNS
- `-email [string]`: the email you would like associated with alerts.
- `-resourceUserName [string]`: the username to use for protected resources
  (e.g. VM administrator).
- `-localNetworkRange [string]`: the
  [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)-formatted
  address range for your local network (e.g. `192.168.1.0/24`).

Optional:

- `-skipConfirmation`: Skips any confirmations with an answer of `yes`.
- `-overwriteParameterFiles`: Overwrites any generated `*.parameters.json` files
  that were created, restoring the default values.

  > **:warning: WARNING!** If you made customizations it will remove them!

### Parameters for the Pipeline-friendly CLI Command

Additional Required Parameters:

- `-resourcePassword [string]`: this password will be set for all accounts
  generated (e.g. VM admin accounts).
- `-certificatePassword [string]`: the password used to encrypt your PFX
  certificate stored at `data/wildcard.pfx`

### Parameters for the Wizard CLI Command

Additional Required Parameters:

- `secureResourcePassword`: this password will be set for all accounts generated
  (e.g. VM admin accounts).
- `secureCertificatePassword`: the password used to encrypt your PFX certificate
  stored at `data/wildcard.pfx`

## Using the PowerShell Script to Automatically Remove the Environment

When you've finished using ADE, you can utilize the same script to remove the
environment from your subscription. You can run the following command for an
interactive session:

`./ade.ps1 -remove`

Or you can add any of the following parameters to execute as a CLI-style script:

- `-alias [string]`: the alias used to deploy ADE
- `-rootDomainName`: the domain name used for Azure DNS
- `-includeKeyVault`: by default, the Azure KeyVault is not removed due to the
  soft-delete feature. You can force remove it by specifying this flag.
- `-skipConfirmation`: Skips any confirmations with an answer of `yes`.

## Allocate or De-allocate Expensive Azure Resources

Some of the Azure resources used in ADE can be very costly when left running for
an extended period of time. To manage your costs, you can de-allocate these
services with the following command:

`./ade.ps1 -deallocate`

This will de-allocate the Application Gateway Firewall, Virtual Machine Scale
Sets, and the AKS clusters. If you need to use these features, you can
re-allocate them by issuing this command:

`./ade.ps1 -allocate`

When running these commands, you'll be prompted for the `alias` used during the
initial deployment of ADE. You can also add the `-alias` parameter to the above
commands to run completely from the CLI.

## More Information

- [Azure Log Analytics](./deployments/azure_log_analytics/azure_log_analytics.md)
- [Azure Policy](./deployments/azure_policy/azure_policy.md)
- [Azure Activity Log](./deployments/azure_activity_log/azure_activity_log.md)
- [Azure Key Vault](./deployments/azure_key_vault/azure_key_vault.md)
- [Azure Identity](./deployments/azure_identity/azure_identity.md)
- [Azure Networking](./deployments/azure_networking/azure_networking.md)
- [Azure VPN Gateway](./deployments/azure_vpn_gateway/azure_vpn_gateway.md)
- [Azure VNET Peering](./deployments/azure_vnet_peering/azure_vnet_peering.md)
- [Azure Firewall](./deployments/azure_firewall/azure_firewall.md)
- [Azure Storage Account VM Diagnostics](./deployments/azure_storage_account_vm_diagnostics/azure_storage_account_vm_diagnostics.md)
- [Azure Bastion](./deployments/azure_bastion/azure_bastion/azure_bastion.md)
- [Azure Virtual Machine Jumpbox](./deployments/azure_virtual_machine_jumpbox/azure_virtual_machine_jumpbox.md)
- [Azure Virtual Machine Developer](./deployments/azure_virtual_machine_developer/azure_virtual_machine_developer.md)
- [Azure Virtual Machine Windows 10 Client](./deployments/azure_virtual_machine_windows_10_client/azure_virtual_machine_windows_10_client.md)
- [Azure Virtual Machine NTier](./deployments/azure_virtual_machine_ntier/azure_virtual_machine_ntier.md)
- [Azure VMSS](./deployments/azure_vmss/azure_vmss.md)
- [Azure Alerts](./deployments/azure_alerts/azure_alerts.md)
- [Azure Container Registry](./deployments/azure_container_registry/azure_container_registry.md)
- [Azure Container Instances Wordpress](./deployments/azure_container_instances_wordpress/azure_container_instances_wordpress.md)
- [Azure Kubernetes Services](./deployments/azure_kubernetes_services/azure_kubernetes_services.md)
- [Azure Kubernetes Services Vote](./deployments/azure_kubernetes_services_vote/azure_kubernetes_services_vote.md)
- [Azure App Service Plan Primary Region](./deployments/azure_app_service_plan_primary_region/azure_app_service_plan_primary_region.md)
- [Azure App Service Plan Secondary Region](./deployments/azure_app_service_plan_secondary_region/azure_app_service_plan_secondary_region.md)
- [Azure App Service Image Resizer](./deployments/azure_app_service_imageresizer/azure_app_service_imageresizer.md)
- [Azure App Service Hello World Primary Region](./deployments/azure_app_service_helloworld_primary_region/azure_app_service_helloworld_primary_region.md)
- [Azure App Service Hello World Secondary Region](./deployments/azure_app_service_helloworld_secondary_region/azure_app_service_helloworld_secondary_region.md)
- [Azure SQL ToDo](./deployments/azure_sql_todo/azure_sql_todo.md)
- [Azure Traffic manager](./deployments/azure_traffic_manager/azure_traffic_manager.md)
- [Azure Application Gateway](./deployments/azure_application_gateway/azure_application_gateway.md)
- [Azure DNS](./deployments/azure_dns/azure_dns.md)
- [Azure Cognitive Services](./deployments/azure_cognitive_services/azure_cognitive_services.md)
