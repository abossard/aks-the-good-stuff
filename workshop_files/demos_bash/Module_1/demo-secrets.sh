#!/usr/bin/bash

CleanUp() {
    
    # SendMessageToCI "kubectl delete deploy workload-2-dep" "Kubectl command:" "Command"
    kubectl delete deploy -l scope=demo
    # SendMessageToCI "kubectl delete secret -l scope=demo" "Kubectl command:" "Command"
    kubectl delete secret -l scope=demo
    exit 
}

# Change to the demo folder
cd Configuration



read -p "Navigate to the Deployments page"
# SendMessageToCI "The following demo illustrates various ways to use Secrets in Kubernetes" "Secrets:" "Info"
echo

read -p "Next Step - Creates initial secrets and deployment"
# SendMessageToCI "kubectl apply -f simple-secret.yaml" "Kubectl command:" "Command"
kubectl apply -f simple-secret.yaml
# SendMessageToCI "kubectl apply -f simple-secret2.yaml" "Kubectl command:" "Command"
kubectl apply -f simple-secret2.yaml
# SendMessageToCI "kubectl apply -f file-secret.yaml" "Kubectl command:" "Command"
kubectl apply -f file-secret.yaml
# SendMessageToCI "kubectl apply -f workload-2-dep.yaml" "Kubectl command:" "Command"
kubectl apply -f workload-2-dep.yaml
echo

read -p "Shell into the Pod and review its settings and files"

CleanUp