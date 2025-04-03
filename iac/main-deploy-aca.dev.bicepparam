using './main-deploy-aca.bicep'

param location = 'eastus2'
param acrName = 'redeus2containerreg01'
param acrSku = 'Basic'
param app_service_prefix = 'red'
param app_service_postfix = 'aca'
