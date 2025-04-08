# Infrastructure as Code (IaC) - Bicep Files

This folder contains Bicep templates for deploying and managing Azure resources. Below is an overview of each file and its purpose.

## Files Overview

### 1. `aks.bicep`

Deploys an Azure Kubernetes Service (AKS) cluster with the following configurable parameters:

- **clusterName**: Name of the AKS cluster.
- **location**: Azure region for the cluster.
- **dnsPrefix**: DNS prefix for the Kubernetes API server.
- **osDiskSizeGB**: Disk size for agent nodes.
- **agentCount**: Number of agent nodes.
- **agentVMSize**: VM size for agent nodes.
- **logwsid**: Log Analytics workspace ID for monitoring.

### 2. `app-configuration.bicep`

Creates an Azure App Configuration resource with key-value pairs. Key features:

- **configStoreName**: Name of the App Configuration store.
- **keyValueNames**: Array of key names.
- **keyValueValues**: Array of corresponding values.
- **contentTypes**: Content types for the key-value pairs.
- **tagsArray**: Optional tags for the key-value pairs.

### 3. `app-service.bicep`

Deploys an Azure App Service with an associated App Service Plan and Application Insights. Key parameters:

- **webAppName**: Name of the web app.
- **sku**: SKU for the App Service Plan.
- **linuxFxVersion**: Runtime stack (e.g., Node.js).
- **logwsid**: Log Analytics workspace ID for diagnostics.

### 4. `container-app.bicep`

Sets up an Azure Container App environment with logging to a Log Analytics workspace. Key parameters:

- **envName**: Name of the container app environment.
- **lawCustomerId**: Log Analytics workspace customer ID.
- **lawSharedKey**: Log Analytics workspace shared key.

### 5. `container-registry.bicep`

Creates an Azure Container Registry (ACR) with role assignments for pulling images. Key parameters:

- **acrName**: Name of the ACR.
- **acrSku**: SKU for the ACR (e.g., Basic).
- **resourcePrincipalId**: Principal ID for role assignment.

### 6. `log-analytics-ws.bicep`

Deploys a Log Analytics workspace for monitoring and diagnostics. Key parameters:

- **prefix**: Prefix for the workspace name.
- **name**: Name of the workspace.
- **location**: Azure region for the workspace.

### 7. `main-deploy-aca.bicep`

Main deployment file for Azure Container Apps. Integrates the following modules:

- Log Analytics workspace (`log-analytics-ws.bicep`)
- Azure Container Registry (`container-registry.bicep`)
- Azure App Configuration (`app-configuration.bicep`)
- Azure Container App environment (`container-app.bicep`)

This is the main Bicep file for deploying Azure Container Apps (ACA).

### 8. `main-deploy-aca.dev.bicepparam`

Parameter file for `main-deploy-aca.bicep`, providing values for development environments.

### 9. `main-deploy-aks.bicep`

Main deployment file for AKS. Integrates the following modules:

- Log Analytics workspace (`log-analytics-ws.bicep`)
- Azure Container Registry (`container-registry.bicep`)
- AKS cluster (`aks.bicep`)

This is the main Bicep file for deploying Azure Kubernetes Service (AKS).

### 10. `main-deploy-app-service.bicep`

Main deployment file for App Service. Integrates the following modules:

- Log Analytics workspace (`log-analytics-ws.bicep`)
- Azure Container Registry (`container-registry.bicep`)
- App Service (`app-service.bicep`)

This is the main Bicep file for deploying Azure App Service.

## Usage

1. Ensure you have the Azure CLI and Bicep CLI installed.
2. Customize the parameter files (e.g., `main-deploy-aca.dev.bicepparam`) as needed.
3. Deploy the templates using the Azure CLI:

   ```bash
   az deployment group create --resource-group <resource-group-name> --template-file <template-file> --parameters <parameter-file>
   ```

## Notes

- Each Bicep file is modular and can be used independently or as part of a main deployment file.
- Ensure proper role assignments and permissions are in place for successful deployments.
