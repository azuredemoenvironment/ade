# Azure Demo Environment

The Azure Demo Environment, aka ADE, is

The Azure Demo Environment (ADE) is designed to deploy a solution to your Azure
Subscription demonstrating many of the Azure service offerings. While not every
possible Azure service is deployed, the purpose of the ADE is to showcase
common, but often more complex, scenarios within Azure, and to be an example to
work from when designing your own solutions.

## Pre-Requisites

To deploy, manage, and remove the Azure Demo Environment, the following
pre-requisites are required. The pre-requisites include software installations
as well as additional service setups (DNS, Certificate Services, and Azure
Subscription Quotas).

### Software Installations

- [PowerShell Core](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

  The Azure CLI is available to install in Windows, macOS and Linux environments.
  - [AZ AKS Preview Extension](https://docs.microsoft.com/en-us/azure/aks/start-stop-cluster)

      To install the AZ AKS Preview Extension, run the following command
      from a terminal:

        az extension add --name aks-preview

      To update to the latest version of the AZ AKS Preview Extension, run
      the following command from a terminal:

        az extension update --name aks-preview

  - [AZ AKS StartStopPreview feature](https://docs.microsoft.com/en-us/azure/aks/start-stop-cluster#register-the-startstoppreview-preview-feature)

      To install the AZ AKS "StartStopPreview" Feature, run the following
      command from a terminal:

        az feature register --namespace "Microsoft.ContainerService" --name "StartStopPreview"

      After registration has finished, enable the "StartStopPreview" feature
      functionality by running the following command from a terminal:

        az provider register --namespace Microsoft.ContainerService

  - [az aks kubectl](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az_aks_install_cli)
  
      To install the AZ AKS Kubectl CLI, run the following command from a
      terminal:

        az aks install-cli
- [Azure PowerShell Cmdlets](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps)

  Azure PowerShell works with PowerShell 6.2.4 and later on all platforms. It is
  also supported with PowerShell 5.1 on Windows

    To install the Azure PowerShell Cmdlets, run the following from an elevated
    PowerShell terminal:

      Install-Module -Name Az -AllowClobber -Scope CurrentUser

    If the following error occurs, "execution of scripts is disabled on this
    system", it is necessary to change the execution policy to allow the running
    of scripts. To modify the PowerShell execution policy, run the following
    from an elevated     PowerShell terminal:

      set-executionpolicy -executionpolicy unrestricted

- [Docker](https://docs.docker.com/get-docker/)

    A system restart is required after the Docker installation. Prior to the
    dployment of ADE, ensure that Docker is **Running**.

### DNS

- The Azure Demo Environment utilizes Azure DNS for publicly accessible A and
  CNAME records for access to Azure Resources including Virtual Machines, Virtual
  Machine Scale Sets, App Services.

- Prior to configuration of Azure DNS, it is necessary to have ownership and
  access to a custom domain.

- ADE requires that an Azure DNS Zone is created prior to deployment of the demo
  environment.

- To create an Azure DNS Zone for ADE, complete the following steps.

  - Create the Azure DNS Zone Resource Group
    - When creating the Azure DNS Zone Resource Group, it is necessary to follow
      the naming convention for ADE:

          rg-ALIAS-REGION_SHORTCODE-dns

    - In this example `ALIAS` represents an unique name that will be used globally,
      within the Azure Demo Environment and `REGION_SHORTCODE` is the shortened
      form of the primary region (e.g. `eus` for the _East US_ region). For example:

          rg-dvader-eus-dns

    - To create the Azure DNS Zone Resource Group using `az`, run the following command:

          az group create -n RESOURCE_GROUP_NAME -l REGION SHORTCODE

          for example:

          az group create -n rg-dvader-eus-dns -l eus

  - Create the Azure DNS Zone
  
  - To create a zone using `az`, run the following command:
    `az network dns zone create -g YOUR_RESOURCE_GROUP_NAME -n YOUR_DOMAIN_NAME`
  - Get the 
    [nameserver](https://docs.microsoft.com/en-us/azure/dns/dns-delegate-domain-azure-dns#retrieve-name-servers)
    entries from Azure DNS and configure your domain at your registrar to use
    them. This can also be done with `az` via this command:
    `az network dns zone show -g YOUR_RESOURCE_GROUP_NAME -n YOUR_DOMAIN_NAME --query nameServers`

### Certificate Services

- A PFX wildcard certificate stored at `data/wildcard.pfx` for the domain name
  to be used with Azure DNS

### Azure Subscription Quotas

- For MSDN Subscriptions or other Subscriptions that have more restrictive resource quotas, open a support ticket and request a quota increase for the following resources:
  - Public IP Addresses (10 - 20)

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
