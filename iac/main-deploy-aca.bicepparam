using './main-deploy-aca.bicep'

param location = '<location>'
param acrName = '<azure-container-registry-name>'
param acrSku = 'Basic'
param app_service_prefix = '<prefix>'
param app_service_postfix = '<postfix>'
param configStoreName = '<app-configuration-name>'
param keyValueNames = [
  'keyName1$labelName'
  'keyName2$labelName'
]
param keyValueValues = [
  'key1Value'
  'key2Value'
]
param contentTypes = [
  'string'
  'string'
]
param tagsArray = [
  {dev: 'dev'}
]
param containerAppEnvName = '<container-app-env-name>'
