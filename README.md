

# Web Api Container App demo

This application is an example web api that has been containerized so it can be deployed into a Azure Container App.

## Description

This project was created initially by using the sample todo .Net web api from the Microsoft learn site:  [Create web API using ASP.NET Core](https://learn.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-6.0&tabs=visual-studio-code).  It is using an InMemory representation of a database to store the `TodoItemDTO` object.  The api supports the basic CRUD operations.  There is also a Dockerfile as part of this project that is used to containerize the app and push it up to Azure Container Registry(ACR).  Once the image is in ACR, it then creates/updates the Azure Container App for the demo web api.  All of this is done in the `deploy-package.yml` GitHub actions workflow.  See workflow section below for more specifics on the workflow.

## Badges

[![Trigger container apps deployment](https://github.com/anotherRedbeard/web-api-demo-container/actions/workflows/deploy-aca-package.yml/badge.svg?branch=main)](https://github.com/anotherRedbeard/web-api-demo-container/actions/workflows/deploy-aca-package.yml)

[![Trigger app service deployment](https://github.com/anotherRedbeard/web-api-demo-container/actions/workflows/deploy-app-service.yml/badge.svg)](https://github.com/anotherRedbeard/web-api-demo-container/actions/workflows/deploy-app-service.yml)

[![Trigger aks app deployment](https://github.com/anotherRedbeard/web-api-demo-container/actions/workflows/deploy-aks-package.yaml/badge.svg)](https://github.com/anotherRedbeard/web-api-demo-container/actions/workflows/deploy-aks-package.yaml)

## How to use

This is meant to be a repo that you can clone and use as you like.  The only thing you will need to change is the variables in the `deploy-package.yml` workflow.  They will be in the `env` section of the workflow.  There will need to change to match the resource names you would like to use in your Azure Subscription.

### Requirements

- **Azure Subscription**
- **This repo cloned in your own GitHub repo**
- **Service principle with contributor access to the subscription created as a GitHub Secret**
  - This is only so you can create your resource group at the subscription level, if you don't want to give your service principle that kind of access you will need to have another way to create the resource group and then you can remove that step from the workflow
  - The credentials for this service principle need to be stored according to this document:  [Service Principal Secret](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Clinux#use-the-azure-login-action-with-a-service-principal-secret)
  - I have used the name `AZURE_CREDENTIALS` for the secret

## GitHub Workflows

### `deploy-aca-package.yml`

The workflow will deploy everything it needs to a given resource group and into an Azure Container App.  It has 4 separate stages: expose-env, build-infra, build, deploy

1. expose-env
    - Unfortunately you need to expose the environment variables that you want to use as output variables so they can be passed into the shared workflow. Ideally it would be nice if you could just use the standard `env` variables
2. build-infra
    - Uses a shared workflow that accepts the variables that were exposed as environment variables in the first stage to create the required infrastructure you need for Azure Container Apps.  These actions are idempotent so they can be run multiple times.
    - The shared workflow is just an example of what you might want to do for your organization to keep things consistent.
3. build
    - Builds the container and tags the image
4. deploy
    - Uses the container image that was built and pushed to ACR and creates/updates that container app with that newly built image

### `deploy-aks-package.yml`

The workflow is using bicep templates to create everything it needs for an AKS cluster into a given resource group.  It has 3 separate stages: buildInfra, buildImage, deploy

1. buildInfra
    - Uses azure credentials to create a resource group via the `az cli` and then calls the `az deployment group create` command to deploy the bicep templates that are stored in the `./iac/` folder.  This will create all the infrastructure you need to support this demo api implementation for AKS.  These actions are idempotent so they can be run multiple times.
2. buildImage
    - Builds the container and tags the image
3. deploy
    - Part of this solution is a UI (Blazor client app) that connects to this todo api. The first part of this stage is to get that URL so we can add it to the CORS list.
    - Next we use a `sed` script to replace variables in the AKS deployment file so it can be dynamic to use the container image we just built.
    - Finally we use the deployment file to setup the deployment in AKS

### `deploy-app-package.yml`

The workflow is using bicep templates to create everything it needs for an App services container deployment for this API. It has 2 separate stages: build-infra, build-deploy

1. build-infra
    - Uses azure credentials to create a resource group via the `az cli` and then calls the `az deployment group create` command to deploy the bicep templates that are stored in the `./iac/` folder.  This will create all the infrastructure you need to support this demo api implementation for AKS.  These actions are idempotent so they can be run multiple times.
2. build-deploy
    - Builds the container, tags the image, and deploys it to container registry.
    - Deploys the container to the app service and sets up the config so it can get the image again for scaling and failures.
