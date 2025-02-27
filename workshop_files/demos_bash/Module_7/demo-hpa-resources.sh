#!/usr/bin/bash

CleanUp () {
    kubectl delete svc complex-web-svc
    kubectl delete deploy complex-web-dep
    kubectl delete deploy complex-web-load
    kubectl delete hpa complex-web-hpa-1
}

# Change to the demo folder
cd HPA

read -p "Navigate to the Settings page"
read -p "Turn off Mini/Micro Pods so Full sized pods are shown"
read -p "Turn ON Show Pod Resources"
read -p "Navigate to the Deployments page"
echo

read -p "Next Step - Creates initial workload"
kubectl apply -f complex-web-dep.yaml -f complex-web-svc.yaml
echo

read -p "Wait for Current Metrics to appear in each pod"
echo

read -p "Next Step - Creates load workload"
kubectl apply -f complex-web-load.yaml
echo

read -p "Wait for Current Metrics to increase in each pod"
echo

read -p "Next Step - Increase load instances"
kubectl scale --replicas=15 deploy/complex-web-load
echo

read -p "Optional - Wait for Current Metrics to increase even more in each pod"
echo

read -p "Next Step - Creates Horizontal Pod Autoscaler"
kubectl apply -f complex-web-hpa.yaml
echo

read -p "Click on the Info (i) icon in the HPA to show Behaviors"
read -p "Wait for number of pods to stabalize"
echo

read -p "Next Step - Decrease load instances"
kubectl scale --replicas=1 deploy/complex-web-load
echo

read -p "Wait for number of pods to decrease"
echo

read -p "Next Step - Delete load instances"
kubectl delete deploy complex-web-load
echo

read -p "Wait for number of pods to decrease down to 2.  Notice the orignal number of instances was 3"
echo

read -p "Next Step - Add another metric to HPA to show it can support more than one"
kubectl apply -f complex-web-hpa2.yaml
echo

CleanUp