//these are all the commands I used to get everything deployed

//create log analytics workspace
az monitor log-analytics workspace create --resource-group ${{ env.resource-group-name }} \
  --workspace-name ${{ env.log-analytics-workspace-name }}

//create acr
az acr create -n <registry_name> -g <resource_group_name> --sku Standard

//connect to ACR
az acr login --name <registry_name>

//push image to registry_name
docker push <registry_url>/<image_name>:<version>

//create new aca environment
az containerapp env create \
  --name $CONTAINERAPPS_ENVIRONMENT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION

//create new aca 
az containerapp create \
  --name my-container-app \
  --resource-group $RESOURCE_GROUP \
  --image $CONTAINER_IMAGE_NAME \
  --environment $CONTAINERAPPS_ENVIRONMENT \
  --registry-server $REGISTRY_SERVER \
  --registry-username $REGISTRY_USERNAME \
  --registry-password $REGISTRY_PASSWORD
  --secrets "queue-connection-string=$CONNECTION_STRING"

//deploys the dockerfile in the . source folder into the ACA environment
az containerapp up -n red-scus-demo-aca --environment dev -g red-scus-fun-with-containers-rg -l southcentralus --source .