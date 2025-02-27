#!/usr/bin/bash

CleanUp(){
    kubectl delete deploy init-dep
}

# Change to the demo folder
cd InitContainers


read -p "Navigate to the Deployments Page"
echo

read -p "Next Step - Creates a multi-container workload with Init Containers"
kubectl apply -f init-dep.yaml
echo

read -p "Click on any of the new pods to view Pod Details.  Watch the containers tabs"
echo

CleanUp
