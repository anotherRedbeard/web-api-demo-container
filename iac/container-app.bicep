param managedEnvironments_dev_env_name string = 'dev-env'

resource managedEnvironments_dev_env_name_resource 'Microsoft.App/managedEnvironments@2024-10-02-preview' = {
  name: managedEnvironments_dev_env_name
  location: 'East US 2'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: 'b1d27951-b4d3-408d-b5ba-bfb87a42826a'
        dynamicJsonColumns: false
      }
    }
    zoneRedundant: false
    kedaConfiguration: {}
    daprConfiguration: {}
    customDomainConfiguration: {}
    workloadProfiles: [
      {
        workloadProfileType: 'Consumption'
        name: 'Consumption'
        enableFips: false
      }
    ]
    peerAuthentication: {
      mtls: {
        enabled: false
      }
    }
    peerTrafficConfiguration: {
      encryption: {
        enabled: false
      }
    }
    publicNetworkAccess: 'Enabled'
  }
}

param containerapps_todo_webapi_aca_name string = 'todo-webapi-aca'
param managedEnvironments_dev_env_externalid string = '/subscriptions/0272c02b-5a38-4b6b-86e6-dcc4ff2ff0e8/resourceGroups/red-eus2-aca-rg/providers/Microsoft.App/managedEnvironments/dev-env'

resource containerapps_todo_webapi_aca_name_resource 'Microsoft.App/containerapps@2024-10-02-preview' = {
  name: containerapps_todo_webapi_aca_name
  location: 'East US 2'
  identity: {
    type: 'None'
  }
  properties: {
    managedEnvironmentId: managedEnvironments_dev_env_externalid
    environmentId: managedEnvironments_dev_env_externalid
    workloadProfileName: 'Consumption'
    configuration: {
      secrets: [
        {
          name: 'redeus2containerreg01azurecrio-redeus2containerreg01'
        }
      ]
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 5209
        exposedPort: 0
        transport: 'Auto'
        traffic: [
          {
            weight: 100
            latestRevision: true
          }
        ]
        allowInsecure: false
      }
      registries: [
        {
          server: 'redeus2containerreg01.azurecr.io'
          username: 'redeus2containerreg01'
          passwordSecretRef: 'redeus2containerreg01azurecrio-redeus2containerreg01'
        }
      ]
      identitySettings: []
    }
    template: {
      containers: [
        {
          image: 'redeus2containerreg01.azurecr.io/todo-webapi:v1.0.29'
          imageType: 'ContainerImage'
          name: containerapps_todo_webapi_aca_name
          env: [
            {
              name: 'CorsAllowedHosts'
              value: 'https://Error'
            }
            {
              name: 'AppConfig__Endpoint'
            }
            {
              name: 'ASPNETCORE_ENVIRONMENT'
              value: 'Staging'
            }
          ]
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
        }
      ]
      scale: {
        maxReplicas: 10
        cooldownPeriod: 300
        pollingInterval: 30
      }
    }
  }
}
