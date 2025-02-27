#!/usr/bin/bash

CleanUp(){
    kubectl delete deployment workload-dep
    kubectl delete scaledobject cron-scaledobject
    
}

# Change to the demo folder
cd KEDA-Cron


read -p "Navigate to the Settings page"
read -p "Turn ON Micro Pods"
read -p "Navigate to the Deployments page"
echo 

read -p "Next Step - Creates initial workload and Cron KEDA scaler"
kubectl apply -f workload-dep.yaml
kubectl apply -f keda-cron.yaml
echo

read -p "Observe pod replicas increase every 2nd minute and decrease every 4th minutes"
read -p "Discuss how this can be used to scale a workload in preparation for a known event"
echo

CleanUp