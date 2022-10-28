// =========== main.bicep ===========
@minLength(1)
@description('The location of the app service')
param location string = resourceGroup().location

@maxLength(10)
@minLength(2)
@description('The name of the app service to create.')
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
    name: app_service_postfix
    location: location
  }
}

// Create app service
module appService './app-service.bicep' = {
  name: 'AppServiceDeployment'
  params: {
    webAppName: app_service_postfix
    sku: app_service_sku
    linuxFxVersion: 'node|14-lts'
    location: location
    logwsid: logws.outputs.id
  }
}

output appServiceName string = appService.outputs.appName
output appServicePlanName string = appService.outputs.aspName
