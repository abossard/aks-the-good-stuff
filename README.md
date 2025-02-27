# Create a cluster with Cilium
https://learn.microsoft.com/en-us/azure/aks/azure-cni-powered-by-cilium

## Bash
```bash
export ARM_SUBSCRIPTION_ID=<your-subscription-id>
export RESOURCE_GROUP_NAME=<your-resource-group>
terraform init
terraform apply -var resource-group-name=$RESOURCE_GROUP_NAME

export CLUSTER_NAME=<your-cluster-name>
```

## PowerShell
```powershell
$env:ARM_SUBSCRIPTION_ID="<your-subscription-id>"
$env:RESOURCE_GROUP_NAME="<your-resource-group>"
terraform init
terraform apply -var "resource-group-name=$env:RESOURCE_GROUP_NAME"

$env:CLUSTER_NAME="<your-cluster-name>"
```

# Connect to the cluster:
az aks get-credentials --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME --overwrite-existing

# Enable Prometheus + Grafana
https://learn.microsoft.com/en-us/azure/aks/monitor-aks?tabs=azure-monitor
Go to the AKS cluster in the Azure portal and select Monitor, enable Prometheus and Grafana.

# Enable Advanced Container Networking
https://learn.microsoft.com/en-us/azure/aks/container-network-observability-how-to?tabs=cilium
az aks update --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME --enable-acns


# How to install ClusterInfo
helm repo add scubakiz https://scubakiz.github.io/clusterinfo/
helm repo update
helm install clusterinfo scubakiz/clusterinfo

# How to access ClusterInfo
kubectl port-forward svc/clusterinfo 5252:5252 -n clusterinfo
open http://localhost:5252

# How to uninstall ClusterInfo
helm uninstall clusterinfo
helm repo remove scubakiz

# Install Traefik Ingress Controller
https://doc.traefik.io/traefik/getting-started/quick-start-with-kubernetes/
kubectl create ns traefik
kubectl apply -f traefik/install.yaml
kubectl port-forward -n traefik svc/traefik-dashboard-service 8080:8080   
open http://localhost:8080/
kubectl apply -f traefik/whoami.yaml

# Key Vault Integration
https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-driver#upgrade-an-existing-aks-cluster-with-azure-key-vault-provider-for-secrets-store-csi-driver-support
az aks enable-addons --addons azure-keyvault-secrets-provider --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP_NAME
kubectl get pods -n kube-system -l 'app in (secrets-store-csi-driver,secrets-store-provider-azure)'



# Install the AKS Store Demo
https://github.com/Azure-Samples/aks-store-demo
kubectl create ns pets

kubectl apply -f https://raw.githubusercontent.com/Azure-Samples/aks-store-demo/main/aks-store-all-in-one.yaml -n pets


# Use the Hubble UI
https://learn.microsoft.com/en-us/azure/aks/container-network-observability-how-to

kubectl apply -f ./hubble-ui.yaml
kubectl port-forward -n kube-system svc/hubble-ui 12000:80

# Add Keda
In the portal
change the Yaml for the product service to autoscale to 100 replicas

# Add a Load Test
https://learn.microsoft.com/en-us/azure/load-testing/quickstart-create-and-run-load-test?tabs=portal
(use curl -X POST to make orders)


# Now switch to cheaper nodes....
https://learn.microsoft.com/en-us/azure/aks/node-autoprovision
disable autoscaling of the system node pool and set it to 1 node.
CriticalAddonsOnly true NoSchedule
az extension add --name aks-preview
az extension update --name aks-preview
az feature register --namespace "Microsoft.ContainerService" --name "NodeAutoProvisioningPreview"
az feature show --namespace "Microsoft.ContainerService" --name "NodeAutoProvisioningPreview"
az provider register --namespace Microsoft.ContainerService
az aks update --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP_NAME --node-provisioning-mode Auto --network-plugin azure --network-plugin-mode overlay --network-dataplane cilium

kubectl get events -A --field-selector source=karpenter -w



# AKS Azure RBAC
https://learn.microsoft.com/en-us/azure/aks/manage-azure-rbac?tabs=azure-cli#enable-azure-rbac-on-an-existing-aks-cluster
az aks update --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME --enable-azure-rbac --enable-aad --disable-local-accounts
az aks get-credentials --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME --overwrite-existing
kubelogin convert-kubeconfig -l azurecli

kubectl api-versions | grep rbac.authorization.k8s.io/v1

kubectl get clusterroles
kubectl describe clusterrole cluster-admin
kubectl get roles --all-namespaces
kubectl get rolebindings --all-namespaces
kubectl get clusterrolebindings
kubectl auth can-i --list
kubectl auth can-i get nodes
# give yourself RBAC Cluster Admin
kubectl auth can-i create deployments.apps --namespace default
az aks update --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME --disable-azure-rbac --enable-local-accounts
az aks get-credentials --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME --overwrite-existing


https://techcommunity.microsoft.com/blog/azuredataexplorer/how-to-monitor-azure-data-explorer-ingestion-using-diagnostic-logs-preview/1107252

https://blog.r0b.io/post/getting-started-with-kube-prometheus-stack/