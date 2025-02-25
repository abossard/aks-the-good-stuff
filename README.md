
# Create a cluster with Cilium
https://learn.microsoft.com/en-us/azure/aks/azure-cni-powered-by-cilium

export ARM_SUBSCRIPTION_ID=<your-subscription-id>

terraform init
terraform plan
terraform apply
export CLUSTER_NAME=<your-cluster-name>
export RESOURCE_GROUP_NAME=<your-resource-group>

# Connect to the cluster:
az aks get-credentials --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME

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

# Install the AKS Store Demo
https://github.com/Azure-Samples/aks-store-demo
kubectl create ns pets

kubectl apply -f https://raw.githubusercontent.com/Azure-Samples/aks-store-demo/main/aks-store-all-in-one.yaml -n pets


# Install Hubble
https://learn.microsoft.com/en-us/azure/aks/container-network-observability-how-to?tabs=cilium#install-hubble-cli
Install the CLI
- Or follow instructions on Windows?

k apply -f ./hubble-ui.yaml
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


