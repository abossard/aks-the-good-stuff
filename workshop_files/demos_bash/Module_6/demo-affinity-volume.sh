#!/usr/bin/bash

CleanUp(){
    kubectl delete deploy pvc-pod-dep
}

# Change to the demo folder
cd AffinityVolume


read -p "Navigate to the Settings page.  Turn on Mini Pods" </dev/tty
read -p "Navigate to the Nodes page" </dev/tty
echo

read -p "Next Step - Creates PVC and Deployment with 6 replicas.  All will be on same node" </dev/tty
kubectl apply -f pvc.yaml
kubectl apply -f pvc-dep-replicas-6.yaml
echo

read -p "Next Step - Increases workload instances.  All still on same node" </dev/tty
kubectl scale --replicas=12 deploy/pvc-pod-dep
echo

read -p "Next Step - Increases workload instances past limit.  Some will remain Pending even if there's room on other nodes" </dev/tty
kubectl scale --replicas=24 deploy/pvc-pod-dep
echo

read -p "Next Step - Change the Affinity rule to Peferred.  Pending pods will be scheduled on other nodes" </dev/tty
kubectl apply -f pvc-dep-replicas-24-peferred.yaml
echo

read -p "Notice that new pods can't start because the volume has already been attached to the other node" </dev/tty
echo

CleanUp