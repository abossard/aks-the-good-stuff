#!/usr/bin/bash

CleanUp(){
    kubectl delete deploy -l app=demo
    kubectl delete service probes-svc
}

# Change to the demo folder
cd Probes


read -p "Navigate to the Settings page"
read -p "Turn OFF Mini and Micro Pods"
read -p "Turn ON Show Containers"
read -p "Navigate to the Namespace"
echo

read -p "Next Step - Creates a Startup Probes"
kubectl apply -f probes-svc.yaml
kubectl apply -f dep-startup-probe.yaml
echo

read -p "Review how the Pod never reaches a Ready state even though it's Running"
read -p "Wait a minute or two and see the how the Restart count increases"
read -p "Navigate to the Services and see how it's not available"
echo

read -p "Navigate to the Namespace"
read -p "Next Step - Create a Liveness Probe"
kubectl apply -f dep-liveness-probe.yaml
echo

read -p "After the Pod is ready, navigate to the Services and see how it's available"
read -p "Wait for a minute or two.  See how it restarts the container, but it stays available"
echo

read -p "Navigate to the Namespace"
read -p "Next Step - Create a Readiness Probe"
kubectl apply -f dep-readiness-probe.yaml
echo

read -p "Navigate to the Services and see how it's not available for about a minute then shows up"
echo

CleanUp