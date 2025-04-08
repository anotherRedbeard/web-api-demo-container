# Web API Container App Demo

## Table of Contents

- [Introduction](#introduction)
- [Description](#description)
- [Badges](#badges)
- [How to Use](#how-to-use)
  - [Requirements](#requirements)
  - [Setup](#setup)
- [GitHub Workflows](#github-workflows)
  - [deploy-aca-package.yml](#deploy-aca-packageyml)
  - [deploy-aks-package.yml](#deploy-aks-packageyml)
  - [deploy-app-service.yml](#deploy-app-serviceyml)
  - [deploy-app-service-image-only.yml](#deploy-app-service-image-onlyyml)

## Introduction

This application is a containerized example of a .NET web API that can be deployed to Azure Container Apps, Azure App Service, or AKS. My attempt is to demonstrates best practices for [continuous deployment of containers](https://learn.microsoft.com/en-us/azure/app-service/deploy-best-practices#continuously-deploy-containers).

## Description

This project is based on the sample ToDo .NET web API from the Microsoft Learn site: [Create web API using ASP.NET Core](https://learn.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-6.0&tabs=visual-studio-code). Additional controllers have been added:

- **TodoController**: Implements CRUD operations using an in-memory database for `TodoItemDTO` objects.
- **WeatherForecastController**: Returns a hardcoded weather forecast for testing purposes.
- **ConfigController**: Demonstrates Azure App Configuration. Learn more about [Azure App Configuration](https://learn.microsoft.com/en-us/azure/azure-app-configuration/overview).

The project includes a Dockerfile for containerization and multiple GitHub Actions workflows. See **Github Worflows** section below for details on each deployment type.

## Badges

| Workflow Name     | Badge |
| ----------- | ----------- |
| Azure Container App Deployment | [![Trigger container apps deployment](https://github.com/anotherRedbeard/web-api-demo-container/actions/workflows/deploy-aca-package.yml/badge.svg?branch=main)](https://github.com/anotherRedbeard/web-api-demo-container/actions/workflows/deploy-aca-package.yml) |
| Azure App Service Deployment | [![Trigger app service deployment](https://github.com/anotherRedbeard/web-api-demo-container/actions/workflows/deploy-app-service.yml/badge.svg)](https://github.com/anotherRedbeard/web-api-demo-container/actions/workflows/deploy-app-service.yml) |
| Azure App Service Slot Deployment | [![Trigger app service deployment of image only](https://github.com/anotherRedbeard/web-api-demo-container/actions/workflows/deploy-app-service-image-only.yml/badge.svg)](https://github.com/anotherRedbeard/web-api-demo-container/actions/workflows/deploy-app-service-image-only.yml) |
| Azure Kubernetes Service (AKS) Deployment   | [![Trigger aks app deployment](https://github.com/anotherRedbeard/web-api-demo-container/actions/workflows/deploy-aks-package.yaml/badge.svg)](https://github.com/anotherRedbeard/web-api-demo-container/actions/workflows/deploy-aks-package.yaml) |

## How to Use

This repository is designed to be cloned and customized. Follow the steps below to set it up.

### Requirements

- **Azure Subscription**
- **GitHub Repository**: Clone this repository into your own GitHub account.
- **Configuration File**: Create an `appsettings.Development.json` file based on the structure in `appsettings.json`.
- **Service Principal**: Create a service principal with Contributor access to your Azure subscription.  The credentials for this service principle need to be stored according to this document:  [Service Principal Secret](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Clinux#use-the-azure-login-action-with-a-service-principal-secret) and stored in a GitHub secret named `AZURE_CREDENTIALS`. You will also need to assign the `User Access Administrator` role because we are doing role assignments in the bicep files.
- **Azure App Configuration Resource** (Optional):
  - Add the following configuration settings:

    | Key     | Value | Label |
    | ----------- | ----------- | -- |
    | TestAp:Settings:Message | DEV - Data from Azure App Configuration | dev |
    | TestAp:Settings:Message | TEST - Data from Azure App Configuration | test |
    | TestAp:Settings:Sentinel | 1 |  |
    | TestAp:<oid for user 1>:Sentinel | ConnectionStringForUser1 |  |
    | TestAp:<oid for user 2>:Sentinel | ConnectionStringForUser2 |  |

  - Replace `<oid for user 1>` and `<oid for user 2>` with actual Object IDs.
  - Create a managed identity and grant it `App Configuration Data Reader` access.

### Setup

1. Clone the repository.
2. Update the `env` section in the workflows with your Azure resource names.
3. Add the `AZURE_CREDENTIALS` secret to your GitHub repository.
4. (Optional) Configure Azure App Configuration as described above.

## GitHub Workflows

This project includes workflows for deploying to Azure Container Apps, App Service, and AKS.

### `deploy-aca-package.yml`

Deploys to Azure Container Apps in four stages:

1. **build**: Builds and tags the container image.
2. **deploy**: Deploys the container image to Azure Container Apps. There is [another repo](https://github.com/anotherRedbeard/blazor-demo-container) that contains a UI (Blazor client app) that will call this `todo`.  There is a reference here to that client UI to get the URI that can be added to CORS. If it doesn't exist it will add `*`.

### `deploy-aks-package.yml`

Deploys to AKS in three stages:

1. **buildInfra**: Creates infrastructure using Bicep templates.
2. **buildImage**: Builds and tags the container image.
3. **deploy**: Deploys the container to AKS and updates CORS settings. While this repo is only for the `todo` api, there is [another repo](https://github.com/anotherRedbeard/blazor-demo-container) that creates a UI (Blazor client app) that connects to this todo api. The first part of this stage is to get that URL so we can add it to the CORS list. Next we use a `sed` script to replace variables in the AKS deployment file so it can be dynamic to use the container image we just built.

### `deploy-app-service.yml`

Deploys to Azure App Service in two stages:

1. **build-infra**: Creates infrastructure using Bicep templates.
2. **build-deploy**: Builds, tags, and deploys the container image.

### `deploy-app-service-image-only.yml`

Demonstrates [slot deployments](https://learn.microsoft.com/en-us/azure/app-service/deploy-staging-slots?tabs=portal) for zero downtime. Stages:

1. **build-deploy**: Builds, tags, and deploys the container image.
2. **swap-slot**: Swaps the staging slot with the production slot after manual approval.

Use the `monitor-api.sh` script to test slot swapping.  It pings the api every 2 seconds to show how the latency isn't impacted by just swapping the slots. If you want, you can create a copy of the `monitor-api.sh` file into an environment specific file `monitor-api.dev.sh` that is ignored by the `.gitignore` file. Here is an example output that shows the response changes from being prefixed with 'green' and then swapped to be prefixed with 'blue':
![Image showing slot swapping response times](./img/monitor-example.png)