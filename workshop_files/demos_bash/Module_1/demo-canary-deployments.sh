#!/usr/bin/bash

CleanUp() {
   
    # SendMessageToCI "kubectl delete deploy canary-1-dep canary-2-dep" "Kubectl command:" "Command"
    kubectl delete deploy canary-1-dep canary-2-dep    
    # SendMessageToCI "kubectl delete svc canary-svc" "Kubectl command:" "Command"
    kubectl delete svc canary-svc
    exit
}

# Change to the demo folder
cd CanaryDeployments

read -p "Open the Deployments page"
# SendMessageToCI "The following demo illustrates a basic canary deployment using Services" "Canary deployments:" "Info"
echo

read -p "Next Step - Creates yellow workload and service"
# SendMessageToCI "kubectl apply -f canary-1-dep.yaml" "Kubectl commands:" "Command"
kubectl apply -f canary-1-dep.yaml
# SendMessageToCI "kubectl apply -f canary-svc.yaml" "Kubectl commands:" "Command"
kubectl apply -f canary-svc.yaml
echo 

read -p "Open the Services page"

read -p "Next Step - Creates red workload with the same label"
# SendMessageToCI "kubectl apply -f canary-2-dep.yaml" "Kubectl commands:" "Command"
kubectl apply -f canary-2-dep.yaml
echo

read -p "Observe how service can select either deployment"

CleanUp