FROM mcr.microsoft.com/azure-cli:latest

# Install Docker Client
################################################

RUN    apk add --update docker openrc tzdata \
    && rc-update add docker boot

# Install PowerShell Core
################################################

# Pre-reqs
RUN    apk update \
    && apk upgrade \
    && apk add --no-cache ca-certificates less ncurses-terminfo-base krb5-libs libgcc libintl libssl1.1 libstdc++ tzdata userspace-rcu zlib icu-libs curl \
    && apk -X https://dl-cdn.alpinelinux.org/alpine/edge/main add --no-cache lttng-ust


# Download and Install PowerShell
RUN    curl -L https://github.com/PowerShell/PowerShell/releases/download/v7.3.0/powershell-7.3.0-linux-alpine-x64.tar.gz -o /tmp/powershell.tar.gz \
    && mkdir -p /opt/microsoft/powershell/7 \
    && tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7 \
    && chmod +x /opt/microsoft/powershell/7/pwsh \
    && ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh

# Install Needed Commandlets
RUN    pwsh -Command "Install-Module -Name Az -AllowClobber -Scope CurrentUser -Force"

# Install AZ Cli Extensions and Configure Environment
################################################
RUN    az extension add --name aks-preview \
    && az aks install-cli

# Copy ADE Assets
################################################

# Make necessary directories
RUN mkdir -p /opt/ade \
    && mkdir /opt/ade/deployments \
    && mkdir -p /opt/ade/modules/ADE

# Switch to new root directory and copy assets
WORKDIR /opt/ade

COPY ./src src
COPY ade.ps1 .
COPY login.ps1 /opt/ade/login.ps1
COPY profile.ps1 /root/.config/powershell/Microsoft.PowerShell_profile.ps1

RUN    chmod 777 ade.ps1 \
    && chmod 777 login.ps1

# Start the Shell
################################################
ENV TZ=UTC
CMD [ "pwsh", "-nologo" ]