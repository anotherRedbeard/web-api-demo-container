

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

## Workflow

The workflow has 4 separate stages: expose-env, build-infra, build, deploy
1. expose-env
    - Unfortunately you need to expose the environment variables that you want to use as output variables so they can be passed into the shared workflow. Ideally it would be nice if you could just use the standard `env` variables
2. build-infra
    - Uses a shared workflow that accepts the variables that were exposed as environment variables in the first stage to create the required infrastructure you need for Azure Container Apps.  These actions are idempotent so they can be run multiple times.
    - The shared workflow is just an example of what you might want to do for your organization to keep things consistent.
3. build
    - Builds the container and tags the image
4. deploy
    - Uses the container image that was built and pushed to ACR and creates/updates that container app with that newly built image
