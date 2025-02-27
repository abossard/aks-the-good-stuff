#!/usr/bin/bash

CleanUp() {
    
    # SendMessageToCI "kubectl delete deploy workload-1-dep" "Kubectl command:" "Command"
    kubectl delete deploy -l scope=demo
    # SendMessageToCI "kubectl delete configmap -l scope=demo" "Kubectl command:" "Command"
    kubectl delete configmap -l scope=demo
    exit 
}

# Change to the demo folder
cd Configuration



read -p "Navigate to the Deployments page"
# SendMessageToCI "The following demo illustrates various ways to use ConfigMaps in Kubernetes" "ConfigMaps:" "Info"
echo

read -p "Next Step - Creates initial configuration and deployment"
# SendMessageToCI "kubectl apply -f simple-configmap.yaml" "Kubectl command:" "Command"
kubectl apply -f simple-configmap.yaml
# SendMessageToCI "kubectl apply -f simple-configmap2.yaml" "Kubectl command:" "Command"
kubectl apply -f simple-configmap2.yaml
# SendMessageToCI "kubectl apply -f file-configmap.yaml" "Kubectl command:" "Command"
kubectl apply -f file-configmap.yaml
# SendMessageToCI "kubectl apply -f workload-1-dep.yaml" "Kubectl command:" "Command"
kubectl apply -f workload-1-dep.yaml
echo

read -p "Shell into the Pod and review its settings and files"

CleanUp