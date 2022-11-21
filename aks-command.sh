#create resource group
az group create --name red-aks-demo-rg  --location southcentralus

#create aks cluster with 2 nodes
az aks create -g red-aks-demo-rg -n myAKSCluster --enable-managed-identity --node-count 2 --enable-addons monitoring --enable-msi-auth-for-monitoring  --generate-ssh-keys

#install kubectl locally if necessary
az aks install-cli

#configure kubectl to connect to your cluster
az aks get-credentials --resource-group red-aks-demo-rg --name myAKSCluster

#confirm connection, this command should return 2 nodes (if that's what you setup above)
kubectl get nodes

#apply yaml for deployment
kubectl apply -f azure-k8s.yaml 

#grant access to ACR from AKS cluster
az aks update -n myAKSCluster -g red-aks-demo-rg --attach-acr redscuscontainerreg000111

#show all pods
kubectl get pods

#show all services
kubectl get services

#show logs
kubectl logs <deployment-name>

#exec to allow you to run commands from within a container
kubectl exec --stdin --tty blazor-deployment-6cbc4b67f4-q48z4 -- sh

#get more detail on item
kubectl describe <service|pod> <service/pod name>