# Azure Demo Environment

The Azure Demo Environment, aka ADE, is a series of PowerShell Scripts, CLI
Script, and Bicep ARM Templates that automatically generates an environment of
Azure Resources and Services to an Azure Subscription. While not every Azure
Service is deployed as a part of ADE, it does showcase many of the common, and
more often complex, scenarios withing Azure, and it can be used as an example
when designing a solution. The Azure Demo Environment is built to be deployed,
deallocated, allocated, removed, and re-deployed. The deployment and removal
processes take approximate two hours. The Azure Demo Environment is an Open
Source Project. Contributions are welcome and encouraged – please visit our
[GitHub Issues](https://github.com/joshuawaddell/azure-demo-environment/issues)
or
[Product Backlog](https://github.com/joshuawaddell/azure-demo-environment/projects/1)
to learn more!

## Prerequisites

To deploy and manage the Azure Demo Environment, the following services and
software must be setup and configured.

### Azure Subscription

- An Azure Subscription is required to deploy the Azure Demo Environment. ADE
  supports Pay-As-You-Go, Enterprise, and MSDN/Visual Studio Subscriptions. The
  resources in ADE do incur charges, but many resources can be deallocated to
  save on costs.

  - For MSDN Subscriptions or other Subscriptions that have more restrictive
    resource quotas, open a support ticket and request a quota increase for the
    following resources:

    - Public IP Addresses (10 - 20)

  **Note: At this time, the Azure Demo Environment is configured to deploy to
  East US (Primary Region), East US 2, and West US (Secondary Region). In a
  future update, other regions will be supported.**

### Software Installations

The only software prerequisite is a local installation of
[Docker](https://docs.docker.com/get-docker/). Prior to the deployment of ADE,
ensure that Docker is **running**.

### DNS

- The Azure Demo Environment utilizes Azure DNS for publicly accessible A
  records for access to Azure App Services. ADE creates an Azure Public DNS Zone
  based on the domain name entered at the time of deployment. It is assumed that
  the user has ownership and access to this custom domain. After the creation of
  the Azure Public DNS Zone, it is necessary to update the DNS Name Servers with
  the Domain Registrar as documented here:

  - Update Domain Registrar with Azure
    [Name Servers](https://docs.microsoft.com/en-us/azure/dns/dns-delegate-domain-azure-dns#retrieve-name-servers).

    - To retrieve the Azure DNS Zone Name Servers using `az`, run the following
      command:

      ```sh
      az network dns zone show -g RESOURCE_GROUP_NAME -n DOMAIN_NAME --query nameServers
      ```

### Certificate Services

- The Azure Demo Environment utilizes a Wildcard SSL Certificate to secure
  multiple services including App Services and Application Gateway. The Wildcard
  PFX must have a password set. There are multiple online services, such as
  [Let's Encrypt](https://letsencrypt.org/getting-started/), that provide free
  and low-cost SSL Certificates.

- **Prior to deploying ADE, it is necessary to store the PFX Wildcard
  Certificate in a dedicated folder locally with the name `wildcard.pfx`.**

## Using the Azure Demo Environment

The Azure Demo Environment is designed to run within a Docker container. To
start ADE, open a terminal and run the following command relevant to your shell
(be sure to set the certificate path variable):

**Bash**

```sh
CERTIFICATE_PATH="/path/to/certificate/data/folder/yourcert.pfx"

docker run \
  -it --rm --name ade \
  -v /var/run/docker.sock:/var/run/docker.sock:rw \
  -v "$CERTIFICATE_PATH:/opt/ade/data/wildcard.pfx" \
  ghcr.io/azuredemoenvironment/ade/ade:latest
```

**PowerShell**

```ps
$CertificatePath = 'C:/path/to/certificate/data/folder/yourcert.pfx'

docker run `
  -it --rm --name ade `
  -v /var/run/docker.sock:/var/run/docker.sock:rw `
  -v "$CertificatePath:/opt/ade/data/wildcard.pfx" `
  ghcr.io/azuredemoenvironment/ade/ade:latest
```

_Note: replace `/path/to/certificate/data/folder/yourcert.pfx` with an absolute
path to your wildcard certificate. E.g., in Windows, it would be like
`C:/Users/username/documents/certificates/yourcert.pfx`, or on macOS it would be
`/users/username/Documents/certificates/yourcert.pfx`._

You now have the ADE Shell Environment! The Azure Demo Environment is deployed
via PowerShell, ARM Templates, and Azure CLI commands, all conveniently wrapped
up in a few ADE Shell commands for your use. All of the commands can be run
interactively, where you are prompted for values, or you can specify them as
parameters to the command.

You are automatically prompted to login to both Azure and Docker Hub once first
entering the container. If you need to login anytime after being in the `ADE`
shell, you can use the `login` command to run the process again.

### Updating to the Latest ADE Release

To update to the latest ADE release, run the following command:

```sh
docker pull ghcr.io/azuredemoenvironment/ade/ade:latest
```

You can then run the `docker run` command from above.

### `deploy` Command

To deploy ADE, simply run the `deploy` command from the ADE shell. You will then
be prompted for various parameters that will be used to customize the demo
environment that is deployed into your subscription.

You can also pass the parameters through the command, for example:

```ps
deploy `
  -alias 'abcdef' `
  -email 'abcdef@website.com' `
  -rootDomainName "website.com" `
  -resourceUserName 'abcdef' `
  -resourcePassword 'SampleP@ssword123!' `
  -certificatePassword 'SampleP@ssword123!' `
  -localNetworkRange '192.168.0.0/24' `
  -skipConfirmation `
  -overwriteParameterFiles
```

#### `deploy` Command Parameters

| Parameter                 | Type   | Required | Description                                                                                                                                    |
| ------------------------- | ------ | -------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| `alias`                   | string | Yes      | Represents an unique name associated with resources used globally within the Azure Demo Environment                                            |
| `rootDomainName`          | string | Yes      | Domain name to be associated with Azure DNS                                                                                                    |
| `email`                   | string | Yes      | Email address to be associated with Azure Alerts                                                                                               |
| `resourceUserName`        | string | Yes      | Username associated with protected Azure Resources (e.g. sqladmin)                                                                             |
| `resourcePassword`        | string | Yes      | Password associated with all accounts (e.g. sqladmin)                                                                                          |
| `certificatePassword`     | string | Yes      | The password used to encrypt the wildcard certificate stored in the `data` folder in the repository, with the name `wildcard.pfx`              |
| `localNetworkRange`       | string | Yes      | [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) formatted address range of the local network (e.g. `192.168.1.0/24`)      |
| `skipConfirmation`        | string | No       | Skips any confirmations with an answer of `yes`                                                                                                |
| `overwriteParameterFiles` | string | No       | Overwrites any generated `*.parameters.json` files that were created and restores the default values. **WARNING:** Removes any customizations. |

### `deallocate` Command

ADE consists of many different Azure services, some of which can be expensive to
run long term. To help reduce spend, the `deallocate` command will spin
resources down that are able to either be in a deallocated state (e.g. Virtual
Machines) or a reduced sku/tier (e.g. AKS). This allows you to keep ADE deployed
within your subscription, but with a lower burden of cost.

#### `deallocate` Command Parameters

| Parameter | Type   | Required | Description                                                                                         |
| --------- | ------ | -------- | --------------------------------------------------------------------------------------------------- |
| `alias`   | string | Yes      | Represents an unique name associated with resources used globally within the Azure Demo Environment |

### `allocate` Command

After you've deallocated ADE, you can use the `reallocate` command to bring
resources back to their original deployed state.

#### `allocate` Command Parameters

| Parameter | Type   | Required | Description                                                                                         |
| --------- | ------ | -------- | --------------------------------------------------------------------------------------------------- |
| `alias`   | string | Yes      | Represents an unique name associated with resources used globally within the Azure Demo Environment |

### `remove` Command

When you no longer want ADE in your Azure subscription, the `remove` command
will tear down the resources that were created. The default behavior will remove
all resources, policies, service principals, and settings with the exception of
Azure Key Vault, due to soft-delete restrictions.

#### `remove` Command Parameters

| Parameter          | Type   | Required | Description                                                                                         |
| ------------------ | ------ | -------- | --------------------------------------------------------------------------------------------------- |
| `alias`            | string | Yes      | Represents an unique name associated with resources used globally within the Azure Demo Environment |
| `rootDomainName`   | string | Yes      | Domain name to be associated with Azure DNS                                                         |
| `includeKeyVault`  | string | No       | Forces the removal of Azure Key Vault                                                               |
| `skipConfirmation` | string | No       | Skips any confirmations with an answer of `yes`                                                     |

### `login` Command

If you've had the ADE Shell Environment open for a substantial period of time
and your Azure or Docker session has timed out, or if you'd like to login with
another account or change your subscription, you can execute the `login` command
to re-login and make subscription selection changes.
