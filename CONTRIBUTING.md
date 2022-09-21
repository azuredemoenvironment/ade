# Contributing

Thank you for your interest in contributing to the Azure Demo Environment! While
ADE is meant to be a quick-to-run solution, there is additional setup required
if you want to contribute to the project.

## Prerequisites

In addition to the pre-requisites for running ADE, you will also need the
following. ADE development is cross-platform, just make sure to install the
OS-appropriate tooling for each of these.

- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Git](https://git-scm.com/)
- [VS Code](https://code.visualstudio.com/) (or other IDE of your choice)

## System Setup

Once you have installed the prerequisites, you will need to clone the ADE repo
locally and open it in VS Code. We recommend having a short `src` folder path
for development in general (e.g. `C:\src\` on Windows or `~/src` on Linux/Mac).
However, if you have a folder already setup for your source code, feel free to
use that.

Inside of your primary source directory, create a new folder called
`azuredemoenvironment`. In there, you'll want to
[clone](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository)
the ADE repositories: [ade](https://github.com/azuredemoenvironment/ade) and
[ade-app](https://github.com/azuredemoenvironment/ade-app).

As is required in the normal ADE workflow, you'll need a **custom domain** that
**you own and/or can update the DNS nameserver entries for**, as well as a
**PFX-formatted** SSL certificate for deploying SSL/TLS secured services. We
recommend that you copy your PFX certificate to
`src/azuredemoenvironment/ade/data/` and rename the file to `wildcard.pfx`.

You should have a directory structure similar to this (in addition to all the
checked out ADE code):

- src (or existing source directory)
  - azuredemoenvironment
    - ade
      - data
        - wildcard.pfx
    - ade-app

## Preparing for Development

Open the `src/azuredemoenvironment` root folder in VS Code. You should see the
two repositories you checked out in the existing steps. Navigate the folder
structure and become familiar with it.

Under the `src/azuredemoenvironment/ade` folder, clone the
`ade.personal.sample.ps1` file to `ade.personal.ps1`. Update this file with your
specific ADE parameters, such as the `alias` and `certificatePassword`, to make
running ADE deployments multiple times easier. This is an ignored file, and
should **never** be checked in to the repository.

Next, open a terminal window (_Terminal -> New Terminal_ in the VS Code
application menu). This may open a bash or PowerShell terminal window, depending
on your OS and VS Code configuration (be mindful, as the commands below are
slightly different due to shell differences).

## Start the ADE Shell Container

In the terminal window, run the following commands (based on the type of shell
you're using), making sure to update the ADE directory variable to be the **full
path** to the `src/azuredemoenvironment/ade` repository folder:

### Bash

```sh
ADE_DIR="/path/to/ade/repository/folder"

docker run \
  -it --rm --name ade \
  -v /var/run/docker.sock:/var/run/docker.sock:rw \
  -v "$ADE_DIR:/opt/ade" \
  -v "$ADE_DIR/profile.ps1:/root/.config/powershell/Microsoft.PowerShell_profile.ps1" \
  ghcr.io/azuredemoenvironment/ade/ade:latest
```

### PowerShell

```ps
$AdeDir = 'C:/path/to/ade/repository/folder'

docker run \
  -it --rm --name ade \
  -v /var/run/docker.sock:/var/run/docker.sock:rw \
  -v "$AdeDir:/opt/ade" \
  -v "$AdeDir/profile.ps1:/root/.config/powershell/Microsoft.PowerShell_profile.ps1" \
  ghcr.io/azuredemoenvironment/ade/ade:latest
```

## Execute a Deployment

When the ADE Shell starts, you'll be prompted to login to the `az` CLI, as well
as selecting a subscription and region to deploy ADE into. Once you've completed
those steps, you can now start a deployment.

Assuming you've updated your `ade.personal.ps1` file with your specific
configuration, you can execute this script from the ADE shell by running the
following command:

```sh
./ade.personal.ps1
```

This will execute a `deploy` command with your configuration. If you need to
re-run a deployment, simply just execute the script again.

## Contribute

Congratulations! You now have a functional development environment. You can now
make changes to the ADE codebase and test them locally within that container.
Unless you modify ADE Shell code (e.g. `profile.ps1`), you should not need to
restart the container; your changes are reflected immediately thanks to the
Docker volume mount in the `docker run` command you used to start the container.

If you leave your container running and your login token expires, you can run
the `Login` command from the ADE prompt to refresh your session. If you want to
change your region or subscription, you can run `ChangeRegion` or
`ChangeSubscription`, respectively.

## Branching

If you're ready to make changes to the codebase, you'll want to
[create a new branch](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-and-deleting-branches-within-your-repository)
to save your work until you're ready to submit a
[pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request).
Our recommended branch naming convention is:
`github-username/XX-short-description`, where `XX` is the issue number you are
working on.

Feel free to make as many commits on your own branch as you'd like to track your
progress. When you're ready to submit a pull request, you can do so directly
from GitHub.

> **Note:** if you're not a member of the Azure Demo Environment organization,
> you'll want to create a
> [fork](https://docs.github.com/en/get-started/quickstart/fork-a-repo) of the
> repository into your own account first, and then branch there.
> [Pull requests can be created from forks](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request-from-a-fork)
> to get back to the main ADE repositories.

## Special Case Development Scenarios

There are a few edge cases where you need to do additional steps to test your
code.

### Virtual Machine Custom Script Extensions

When working in branch that isn't `main`, you'll need to specify a parameter to
allow the Virtual Machine deployment scripts to be found. Add the following
after your `deploy` command in your `ade.personal.ps1` file::

```ps
 -scriptsBaseUri 'https://raw.githubusercontent.com/azuredemoenvironment/ade/your/branch/name/scripts'
```

Update the `your/branch/name` section to match the path of your branch. This
allows you to pull the CSE scripts from your branch instead of the `main`
branch.
