#!/usr/bin/bash

CleanUp() {
    kubectl delete deploy workload-1-dep -n default
    exit 
}

# Change to the demo folder
cd BasicDeployments/



read -p "Navigate to the Deployments page"
# SendMessageToCI "The following demo illustrates the basic Kubernetes depread Basic Deplread Info"
echo 

read -p "Next Step - Creates initial deployments"
# SendMessageToCI "kubectl apply -f workload-1-dep-lime.yaml read Kubectl read Command"
kubectl apply -f workload-1-dep-lime.yaml --record
echo

read -p "Next Step - Updates the deployment to trigger a new replica set"
# SendMessageToCI "labels:\n  colorread Deployment YAML read Code"
kubectl apply -f workload-1-dep-yellow.yaml --record
echo

read -p "Next Step - Updates the deployment again, adding minReadySeconds"
# SendMessageToCI "spec:\n  minReadySecread Deployment YAML read Code"
# SendMessageToCI "labels:\n  colorread Deployment YAML read Code"
kubectl apply -f workload-1-dep-maroon.yaml --record
echo

read -p "Observe and explain toolbar buttons"
read -p  "Next Step - Undoes rollout to bring pevious replica set back"
# SendMessageToCI "kubectl rollout undo deploy workloread Kubectl read Command"
kubectl rollout undo deploy workload-1-dep
echo

read -p "Next Step - Changes color label to trigger a new replica set"
# SendMessageToCI "labels:\n  colread Deployment YAML read Code"
kubectl apply -f workload-1-dep-pink.yaml --record
echo

read -p "Open the Deployment Info Panel by clicking the Info (i) icon to the right of the deployment name"
read -p "Next Step - Changes color label and INVALID image.  See what happenes with the new replica set"
# SendMessageToCI "containers:\n- image: nginxread Deployment YAML read Code"
kubectl apply -f workload-1-dep-aqua-invalid.yaml --record
echo

read -p "Next Step - Undoes rollout to pevious replica set"
# SendMessageToCI "kubectl rollout undo deploy workloread Kubectl read Command"
kubectl rollout undo deploy workload-1-dep
echo

read -p "Next Step - Undoes rollout back to Rev 1"
# SendMessageToCI "kubectl rollout undo deploy workload-1-dep --to-reread Kubectl read Command"
kubectl rollout undo deploy workload-1-dep --to-revision=1
echo

read -p "Next Step - Changes deployment strategy to Recreate"
# SendMessageToCI "strategy:\n  type: read Deployment YAML read Code"
kubectl apply -f workload-1-dep-blue-recreate.yaml
echo

read -p "Next Step - Changes deployment strategy to Rolling Update and sets Revision History"
# SendMessageToCI "strategy:\n  type: RollingUpdate\nrevisionHistoryread Deployment YAML read Code"
kubectl apply -f workload-1-dep-orange-revision-history.yaml
echo

CleanUp 