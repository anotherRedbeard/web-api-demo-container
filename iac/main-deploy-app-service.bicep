// =========== main.bicep ===========
@minLength(1)
@description('The location of the app service')
param location string = resourceGroup().location

@maxLength(10)
@minLength(2)
@description('The name of the app service to create.')
param app_service_postfix string 

@allowed([
  'F1'
])
@description('The name of the app service sku.')
param app_service_sku string

// =================================

// Create app service
module appService './app-service.bicep' = {
  name: 'AppServiceDeployment'
  params: {
    webAppName: app_service_postfix
    sku: app_service_sku
    linuxFxVersion: 'node|14-lts'
    location: location
  }
}

output appServiceName string = appService.name
