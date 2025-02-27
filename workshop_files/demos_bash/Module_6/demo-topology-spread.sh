#!/usr/bin/bash

CleanUp(){
    kubectl delete deploy workload
}

# Change to the demo folder
cd TopologySpread

read -p "This demo assumes you have 3 nodes" 
read -p "Navigate to the Settings page.  Turn on Micro Pods"
read -p "Navigate to the Nodes page" 
echo

read -p "Next Step - Create the initial workflow with 3 replicas" 
kubectl apply -f workload.yaml
read -p "Notice how Pods are evenly spread out across the nodes" 
echo

read -p "Next Step - Increases workload to 12 instances" 
kubectl scale --replicas=12 deploy/workload
read -p "Notice how Pods are still being evenly spread out across the nodes" 
echo

read -p "Next Step - Increases workload to 22 instances" 
kubectl scale --replicas=19 deploy/workload
read -p "Notice how Pods are still being evenly spread out WITHOUT exceeing MaxSkew" 
echo

read -p "Next Step - Decrease workload instances again" 
kubectl scale --replicas=6 deploy/workload
read -p "Notice how Pods may NOT be deleted evenly between the nodes" 
read -p "This constraint only works during scheduling, not deletions." 
echo

read -p "Next Step - Increases workload to 45 instances, which is more than 3 nodes can support" 
kubectl scale --replicas=45 deploy/workload
read -p "The auto scaler should start creating additional nodes" 
read -p "Notice how some Pods are still pending but there's still room on some nodes" 
read -p "This is because MaxSkew is set to 1, so there can be no more than 1 pod count difference between nodes" 
read -p "Remaining Pods will be scheduled on new node, even though there will" 
read -p "be a difference higher than MaxSkew.  It will NOT rebalance the Nodes." 
read -p "Some Pods may stay Pending, even though there's room on some of the Nodes." 
read -p "Again this is because of MaxSkew" 
echo

read -p "Next Step - Set MaxSkew to 3 and patch the deployment" 
kubectl patch deploy workload --patch-file patch-maxskew-3.yaml
read -p "The scheduler will now redeploy the pods (new replica set) and allow a difference of 3 Pods between nodes" 
echo

read -p "Next Step - Set MaxSkew to 1, WhenUnsatisfiable to ScheduleAnyway.  Patch the deployment" 
kubectl patch deploy workload --patch-file patch-schedule-anyway.yaml
echo
read -p "The scheduler will now redeploy the pods and allow all Pods to be scheduled regardless of MaxSkew"
read -p "This setting is not very different from not having any constraints at all" 
echo

CleanUp