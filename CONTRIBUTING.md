# Contributing

Thank you for your interest in contributing to the Azure Demo Environment! While
ADE is meant to be a quick-to-run solution, there is additional setup required
if you want to contribute to the project.

## Pre-requisites

In addition to the pre-requisites for running ADE, you will also want or need
the following. ADE development is cross-platform, just make sure to install the
OS-appropriate tooling for each of these.

- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Git](https://git-scm.com/)
- [VS Code](https://code.visualstudio.com/) (or other IDE of your choice)

## System Setup

Once you have installed the prereqs, you will need to clone the ADE repo locally
and open it in VS Code. We recommend having a short `src` folder path for
development in general (e.g. `C:\src\` on Windows or `~/src` on Linux/Mac).
However, if you have a folder already setup for your source code, feel free to
use that.

Inside of your primary source directory, create a new folder called
`azuredemoenvironment`. In there, you'll want to
[clone](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository)
the ADE repositories: [ade](https://github.com/azuredemoenvironment/ade) and
[ade-app](https://github.com/azuredemoenvironment/ade-app).

You should have a directory structure similar to this:

- src
  - azuredemoenvironment
    - ade
    - ade-app

As is required in the normal ADE workflow, you'll need an SSL certificate for
deploying SSL/TLS secured services. We recommend that you copy your PFX
certificate to `src/azuredemoenvironment/ade/data/` and rename the file to
`wildcard.pfx`.

## Mounting ADE to the Docker Container

You can run the following command to mount your locally checked-out source to
the Docker container:

```sh
docker run \
  -it --rm --name ade \
  -v /var/run/docker.sock:/var/run/docker.sock:rw \
  -v /path/to/local/ade:/opt/ade \
  ghcr.io/azuredemoenvironment/ade/ade:latest
```

## Using the Current Branch Deployment Scripts

When working in branch that isn't `main`, you'll need to specify a parameter to
allow the Virtual Machine deployment scripts to be found. Add the following
after your `deploy` command:

```ps
 -scriptsBaseUri 'https://raw.githubusercontent.com/azuredemoenvironment/ade/your/branch/name/scripts'
```

For example:

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
  -overwriteParameterFiles `
  -scriptsBaseUri 'https://raw.githubusercontent.com/azuredemoenvironment/ade/dev/scripts'
```
