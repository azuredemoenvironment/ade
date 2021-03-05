##################################################################
# Stage 0: Set the Base Primary Image of the App
##################################################################
FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS base

WORKDIR /app

EXPOSE 80
EXPOSE 443

##################################################################
# Stage 1: Set the Base Development Image of the App
##################################################################
FROM mcr.microsoft.com/dotnet/sdk:5.0 AS baseDev

WORKDIR /app

##################################################################
# Stage 2: Build the .NET Core App
##################################################################
FROM baseDev AS publish

# Copy all needed project files for restore purposes (sorted by likeliness of change)
# NOTE: this is assuming the context is set to the parent directory
WORKDIR /app

# Shared Libraries
COPY ./ADE.DataContracts/*.csproj ./ADE.DataContracts/
COPY ./ADE.DataAccess/*.csproj ./ADE.DataAccess/
COPY ./ADE.ServiceBase/*.csproj ./ADE.ServiceBase/

# App
COPY ./ADE.DataReporterService/*.csproj ./ADE.DataReporterService/

# Scope to app directory and run the restore process
WORKDIR /app/ADE.DataReporterService
RUN dotnet restore

# Copy all files to build the project (sorted by likeliness of change)
# NOTE: this is assuming the context is set to the parent directory
WORKDIR /app

# Shared Libraries
COPY ./ADE.DataContracts/ ./ADE.DataContracts/
COPY ./ADE.DataAccess/ ./ADE.DataAccess/
COPY ./ADE.ServiceBase/ ./ADE.ServiceBase/

# App
COPY ./ADE.DataReporterService/ ./ADE.DataReporterService/

# Scope to app directory and run the publish to generate the artifacts
WORKDIR /app/ADE.DataReporterService
ARG BuildConfiguration=Debug
RUN dotnet publish -c $BuildConfiguration -o out

##################################################################
# Stage 3: Copy Into a Clean Runtime Image
##################################################################
FROM base AS final

# Copy artifacts from the previous stage into this stage
COPY --from=publish /app/ADE.DataReporterService/out ./

# Setting the executable that will run in the lifetime of this container
ENTRYPOINT ["dotnet", "ADE.DataReporterService.dll"]