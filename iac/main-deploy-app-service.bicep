// =========== main.bicep ===========
@minLength(1)
@description('The location of the app service')
param location string = resourceGroup().location

@minLength(5)
@maxLength(50)
@description('Provide a globally unique name of your Azure Container Registry')
param acrName string = 'acr${uniqueString(resourceGroup().id)}'

@description('Provide a tier of your Azure Container Registry.')
param acrSku string = 'Basic'

@maxLength(10)
@minLength(2)
@description('The prefix name of the app service to create.')
param app_service_prefix string 

@maxLength(10)
@minLength(2)
@description('The postfix name of the app service to create.')
param app_service_postfix string 

@allowed([
  'B1'
])
@description('The name of the app service sku.')
param app_service_sku string



// =================================

// Create Log Analytics workspace
module logws './log-analytics-ws.bicep' = {
  name: 'LogWorkspaceDeployment'
  params: {
    prefix: app_service_prefix
    name: app_service_postfix
    location: location
  }
}

// Create Container Registry
module acr 'container-registry.bicep' = {
  name: 'ContainerRegistryDeployment'
  params: {
    acrName: acrName
    location: location
    acrSku: acrSku
    //you will need write permission to do this which is more than a Contributor
    resourcePrincipalId: appService.outputs.principalId
  }
}

// Create app service
module appService './app-service.bicep' = {
  name: 'AppServiceDeployment'
  params: {
    prefix: app_service_prefix
    webAppName: app_service_postfix
    sku: app_service_sku
    linuxFxVersion: 'node|14-lts'
    location: location
    logwsid: logws.outputs.id
  }
}

output appServiceName string = appService.outputs.appName
output appServicePlanName string = appService.outputs.aspName
