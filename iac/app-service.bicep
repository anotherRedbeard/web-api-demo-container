param webAppName string = uniqueString(resourceGroup().id) // Generate unique String for web app name
param sku string = 'P0V3' // The SKU of App Service Plan
param linuxFxVersion string = 'node|14-lts' // The runtime stack of web app
param location string = resourceGroup().location // Location for all resources
param logwsid string
param prefix string
var appServicePlanName = toLower('${prefix}-AppServicePlan-${webAppName}')
var appInsightsName = toLower('${prefix}-AppInsights-${webAppName}')
var webSiteName = toLower('${prefix}-webApp-${webAppName}')

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: sku
  }
  kind: 'linux'
}

// Create application insights
resource appi 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    Request_Source: 'rest'
    RetentionInDays: 30
    WorkspaceResourceId: logwsid
  }
 }

resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: webSiteName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      acrUseManagedIdentityCreds: true
      linuxFxVersion: linuxFxVersion
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appi.properties.InstrumentationKey
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~2'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appi.properties.ConnectionString
        }
        {
          name: 'ApplicationInsights__ConnectionString'
          value: appi.properties.ConnectionString
        }
      ]
    }
  }
}
resource stageSlot 'Microsoft.Web/sites/slots@2020-06-01' = {
  parent: appService
  name: 'stage'
  location: location
  kind: 'app,linux,container'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      acrUseManagedIdentityCreds: true
      appSettings: [
        {
          name: 'CorsAllowedHosts'
          value: '*'
        }
        {
          name: 'AppConfig__Endpoint'
          value: ''
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appi.properties.InstrumentationKey
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~2'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appi.properties.ConnectionString
        }
        {
          name: 'ApplicationInsights__ConnectionString'
          value: appi.properties.ConnectionString
        }
      ]
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Return the app service name and farm name
output appName string = appService.name
output aspName string = appServicePlan.name
output appInsightsName string = appi.name
output principalId string = appService.identity.principalId
output slotPrincipalId string = stageSlot.identity.principalId
