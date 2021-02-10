# Azure Demo Environment

The Azure Demo Environment, aka ADE, is a series of PowerShell Scripts, CLI
Script, and ARM Templates that automatically generates an environment of Azure
Resources and Services to an Azure Subscription. While not every Azure Service
is deployed as a part of ADE, it does showcase many of the common, and more
often complex, scenarios withing Azure, and it can be used as an example when
designing a solution. The Azure Demo Environment is built to be deployed,
deallocated, allocated, removed and re-deployed. The deployment and removal
processes take approximate two hours. Instructions are provided below. The Azure
Demo Environment is an Open Source Project. Contributions are welcome and
encouraged!

## Prerequisites

To deploy, manage, and remove the Azure Demo Environment, the following
prerequisites are required. The prerequisites include and Azure Subscription,
software installations as well as additional service setups such as DNS and
Certificate Services.

### Azure Subscription

- An Azure Subscription is required to deploy the Azure Demo Environment. ADE
  supports Pay As You Go, Enterprise, and MSDN Subscriptions. The resources in
  ADE do incur charges, but many resources can be deallocated to save on cost.

  - For MSDN Subscriptions or other Subscriptions that have more restrictive
    resource quotas, open a support ticket and request a quota increase for the
    following resources:

    - Public IP Addresses (10 - 20)

  **Note: At this time, the Azure Demo Environment is configured to deploy to
  East US (Primary Region), East US 2, and West US (Secondary Region). In a
  future update, other regions will be supported.**

### Software Installations

- [PowerShell Core](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

  The Azure CLI is available to install in Windows, macOS and Linux
  environments.

  - [AZ AKS Preview Extension](https://docs.microsoft.com/en-us/azure/aks/start-stop-cluster)

    To install the AZ AKS Preview Extension, run the following command from a
    terminal:

    ```sh
    az extension add --name aks-preview
    ```

    To update to the latest version of the AZ AKS Preview Extension, run the
    following command from a terminal:

    ```sh
    az extension update --name aks-preview
    ```

  - [AZ AKS StartStopPreview feature](https://docs.microsoft.com/en-us/azure/aks/start-stop-cluster#register-the-startstoppreview-preview-feature)

    To install the AZ AKS "StartStopPreview" Feature, run the following command
    from a terminal:

    ```sh
    az feature register --namespace "Microsoft.ContainerService" --name "StartStopPreview"
    ```

    After registration has finished, enable the "StartStopPreview" feature
    functionality by running the following command from a terminal:

    ```sh
    az provider register --namespace Microsoft.ContainerService
    ```

  - [az aks kubectl](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az_aks_install_cli)

    To install the AZ AKS Kubectl CLI, run the following command from a
    terminal:

    ```sh
    az aks install-cli
    ```

- [Azure PowerShell Cmdlets](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps)

  Azure PowerShell works with PowerShell 6.2.4 and later on all platforms. It is
  also supported with PowerShell 5.1 on Windows

  To install the Azure PowerShell Cmdlets, run the following from an elevated
  PowerShell terminal:

  ```ps
  Install-Module -Name Az -AllowClobber -Scope CurrentUser
  ```

  If the following error occurs, "execution of scripts is disabled on this
  system", it is necessary to change the execution policy to allow the running
  of scripts. To modify the PowerShell execution policy, run the following from
  an elevated PowerShell terminal:

  ```ps
  Set-ExecutionPolicy -executionpolicy unrestricted
  ```

- [Docker](https://docs.docker.com/get-docker/)

  A system restart is required after the Docker installation. Prior to the
  deployment of ADE, ensure that Docker is **running**.

### DNS

- The Azure Demo Environment utilizes Azure DNS for publicly accessible A and
  CNAME records for access to Azure Resources including Virtual Machines,
  Virtual Machine Scale Sets, App Services. ADE requires that an Azure DNS Zone
  is created prior to deployment of the demo environment. **Note: Prior to
  configuration of an Azure DNS Zone, it is necessary to have ownership and
  access to a custom domain.**

- To create and configure an Azure DNS Zone for use with ADE, complete the
  following steps.

  - Create the Azure DNS Zone Resource Group

    - When creating the Azure DNS Zone Resource Group, it is necessary to follow
      the naming convention for ADE:

      `rg-ALIAS-REGION_SHORTCODE-dns`

    - In this example `ALIAS` represents an unique name associated with
      resources used globally within the Azure Demo Environment and
      `REGION_SHORTCODE` is the shortened form of the primary region (e.g. `eus`
      for the _East US_ region). For example:

      `rg-dvader-eus-dns`

      **Note: At this time, it is necessary to utilize `eus` as the
      `REGION_SHORTCODE`, due to the current configuration of ADE. In a future
      update, other regions will be supported.**

    - To create the Azure DNS Zone Resource Group using `az`, run the following
      command:

      ```sh
      az group create -n RESOURCE_GROUP_NAME -l REGION SHORTCODE
      ```

      For example:

      ```sh
      az group create -n rg-dvader-eus-dns -l eus
      ```

  - Create the Azure DNS Zone

    - To create the Azure DNS Zone using `az`, run the following command:

      ```sh
      az network dns zone create -g RESOURCE_GROUP_NAME -n DOMAIN_NAME
      ```

      For example:

      ```sh
      az network dns zone create -g rg-dvader-eus-dns -n darthvader.com
      ```

  - Update Domain Registrar with Azure
    [Name Servers](https://docs.microsoft.com/en-us/azure/dns/dns-delegate-domain-azure-dns#retrieve-name-servers).

    - After the creation of the Azure DNS Zone, it is necessary to update the
      DNS Name Servers with the Domain Registrar. To retrieve the Azure DNS Zone
      Name Servers using `az`, run the following command:

      ```sh
      az network dns zone show -g RESOURCE_GROUP_NAME -n DOMAIN_NAME --query nameServers
      ```

### Certificate Services

- The Azure Demo Environment utilizes a Wildcard SSL Certificate to secure
  multiple services including App Services and Application Gateway. There are
  multiple online services, such as
  [Let's Encrypt](https://letsencrypt.org/getting-started/), that provide free
  to low cost SSL Certificates.

- **Prior to deploying ADE, it is necessary to store the PFX Wildcard
  Certificate in the `data` folder in the repository, with the name
  `wildcard.pfx`.**

## Using the Azure Demo Environment

### Deploying the Azure Demo Environment

The Azure Demo Environment is deployed via a PowerShell Script and a series of
ARM Templates and Azure CLI commands. There are two methods of utilizing the
script, a pipeline friendly CLI Script, and a CLI Script Wizard. To deploy the
Azure Demo Environment, execute the following steps:

- Login to Azure

  - Open a Terminal, Command Prompt, or PowerShell session, and navigate to the
    root of the cloned repository.
  - To login to Azure using `az`, run the following command:

    ```sh
    az login
    ```

    The CLI will open a default browser and redirect to the Azure login page.
    Enter the appropriate credentials and return to the Terminal, Command
    Prompt, or PowerShell session.

  - To retrieve a list of available subscriptions associated with the
    credentials used in the previous step using `az`, run the following command:

    ```sh
    az account list --output table
    ```

  - To select the subscription to use with ADE using `az`, run the following
    command:

    ```sh
    az account set --subscription "Subscription Name"
    ```

- Deploy the Azure Demo Environment Using the CLI Script (Pipeline Friendly)

  - From the Terminal, Command Prompt, or PowerShell session, execute the
    following (sample) command:

    ```ps
    ./ade.ps1 -deploy \
      -alias 'abcdef' \
      -email 'abcdef@website.com' \
      -rootDomainName "website.com" \
      -resourceUserName 'abcdef' \
      -resourcePassword 'SampleP@ssword123!' \
      -certificatePassword 'SampleP@ssword123!' \
      -localNetworkRange '192.168.0.0/24' \
      -skipConfirmation \
      -overwriteParameterFiles
    ```

- Deploy the Azure Demo Environment Using the CLI Script (Wizard)

  - From the Terminal, Command Prompt, or PowerShell session, execute the
    following command:

    ```ps
    ./ade.ps1 -deploy
    ```

#### Parameters for CLI Script (Pipeline Friendly) and CLI Script (Wizard)

- Required Parameters:

  | Parameter            | Type   | Description                                                                                                                               |
  | -------------------- | ------ | ----------------------------------------------------------------------------------------------------------------------------------------- |
  | `-alias`             | string | Represents an unique name associated with resources used globally within the Azure Demo Environment                                       |
  | `-rootDomainName`    | string | Domain name to be associated with Azure DNS                                                                                               |
  | `-email`             | string | Email address to be associated with Azure Alerts                                                                                          |
  | `-resourceUserName`  | string | Username associated with protected Azure Resources (e.g. sqladmin)                                                                        |
  | `-localNetworkRange` | string | [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) formatted address range of the local network (e.g. `192.168.1.0/24`) |

- Optional Parameters:

  | Parameter                  | Type   | Description                                                                                                                                    |
  | -------------------------- | ------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
  | `-skipConfirmation`        | string | Skips any confirmations with an answer of `yes`                                                                                                |
  | `-overwriteParameterFiles` | string | Overwrites any generated `*.parameters.json` files that were created and restores the default values. **WARNING:** Removes any customizations. |

#### Parameters for the CLI Script (Pipeline Friendly)

- Additional Required Parameters:

  | Parameter              | Type   | Description                                                                                                                       |
  | ---------------------- | ------ | --------------------------------------------------------------------------------------------------------------------------------- |
  | `-resourcePassword`    | string | Password associated with all accounts (e.g. sqladmin)                                                                             |
  | `-certificatePassword` | string | The password used to encrypt the wildcard certificate stored in the `data` folder in the repository, with the name `wildcard.pfx` |

#### Parameters for the CLI Script (Wizard)

- Additional Required Parameters:

  | Parameter                   | Type   | Description                                                                                                                       |
  | --------------------------- | ------ | --------------------------------------------------------------------------------------------------------------------------------- |
  | `secureResourcePassword`    | string | Password associated with all accounts (e.g. sqladmin)                                                                             |
  | `secureCertificatePassword` | string | The password used to encrypt the wildcard certificate stored in the `data` folder in the repository, with the name `wildcard.pfx` |

### Deallocate or Allocate the Azure Demo Environment

To save money on Resource Costs, an allocate and deallocate function has been
built into the environment. These commands will allocate / deallocate the Azure
Firewall, Azure Virtual Machines, Azure Virtual Machine Scale Sets. Azure
Kubernetes Service clusters, and Azure Container Instances.

- Deallocate the Azure Demo Environment

  - From the Terminal, Command Prompt, or PowerShell session, execute the
    following command:

    ```ps
    ./ade.ps1 -deallocate
    ```

- Allocate the Azure Demo Environment

  - From the Terminal, Command Prompt, or PowerShell session, execute the
    following command:

    ```ps
    ./ade.ps1 -allocate
    ```

  Note: The commands will prompt for the value of `alias` used during the
  initial deployment of ADE. Additionally, the `alias` parameter can be added to
  the command at execution.

### Remove the Azure Demo Environment

The Azure Demo Environment can be removed using the same script that creates,
allocates, and deallocates the environment. The default behavior will will
remove all resources, policies, service principals, and settings with the
exception of Azure Key Vault, due to soft-delete restrictions.

- Remove the Azure Demo Environment

  - From the Terminal, Command Prompt, or PowerShell session, execute the
    following command:

    ```ps
    ./ade.ps1 -remove
    ```

  Note: The removal command will prompt for the value of `alias`, and
  `rootDomainName` in an interactive session. Additionally, the following
  parameters can be added at execution of the removal command:

  | Parameter           | Type   | Description                                                                                         |
  | ------------------- | ------ | --------------------------------------------------------------------------------------------------- |
  | `-alias`            | string | Represents an unique name associated with resources used globally within the Azure Demo Environment |
  | `-rootDomainName`   | string | Domain name to be associated with Azure DNS                                                         |
  | `-includeKeyVault`  | string | Forces the removal of Azure Key Vault                                                               |
  | `-skipConfirmation` | string | Skips any confirmations with an answer of `yes`                                                     |

## Documentation

The links below detail each deployment including all services, and dependencies.

- [Azure Log Analytics](./deployments/azure_log_analytics/azure_log_analytics.md)
- [Azure Policy](./deployments/azure_policy/azure_policy.md)
- [Azure Activity Log](./deployments/azure_activity_log/azure_activity_log.md)
- [Azure Key Vault](./deployments/azure_key_vault/azure_key_vault.md)
- [Azure Identity](./deployments/azure_identity/azure_identity.md)
- [Azure Networking](./deployments/azure_networking/azure_networking.md)
- [Azure VPN Gateway](./deployments/azure_vpn_gateway/azure_vpn_gateway.md)
- [Azure VNET Peering](./deployments/azure_vnet_peering/azure_vnet_peering.md)
- [Azure Storage Account VM Diagnostics](./deployments/azure_storage_account_vm_diagnostics/azure_storage_account_vm_diagnostics.md)
- [Azure NSG FLow Logs](./deployments/azure_nsg_flow_logs/azure_nsg_flow_logs.md)
- [Azure Firewall](./deployments/azure_firewall/azure_firewall.md)
- [Azure Private DNS](deployments/azure_private_dns/azure_private_dns.md)
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
- [Azure App Service Inspector Gadget](deployments/azure_private_link_inspectorgadget/azure_private_link_inspectorgadget.md)
- [Azure App Service Hello World Primary Region](./deployments/azure_app_service_helloworld_primary_region/azure_app_service_helloworld_primary_region.md)
- [Azure App Service Hello World Secondary Region](./deployments/azure_app_service_helloworld_secondary_region/azure_app_service_helloworld_secondary_region.md)
- [Azure SQL ToDo](./deployments/azure_sql_todo/azure_sql_todo.md)
- [Azure Traffic manager](./deployments/azure_traffic_manager/azure_traffic_manager.md)
- [Azure Application Gateway](./deployments/azure_application_gateway/azure_application_gateway.md)
- [Azure DNS](./deployments/azure_dns/azure_dns.md)
- [Azure Cognitive Services](./deployments/azure_cognitive_services/azure_cognitive_services.md)
