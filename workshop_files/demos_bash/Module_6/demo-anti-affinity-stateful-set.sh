#!/usr/bin/bash

CleanUp() {
    kubectl delete statefulset/pvc-pod-ss
    kubectl delete service/pvc-pod-svc
}

# Change to the demo folder
cd AntiAffinityStatefulSet


read -p "Navigate to the Settings page.  Turn off Mini/Micro Pods so Full sized pods are shown" </dev/tty
read -p "Navigate to the Nodes page" </dev/tty
echo

read -p "Next Step - Creates initial workloads of Stateful Set with 2 instances" </dev/tty
kubectl apply -f pvc-ss.yaml
echo

read -p "Next Step - Increase stateful set instances" </dev/tty
kubectl scale --replicas=3 statefulset/pvc-pod-ss
echo

read -p "Notice the events of the Pending pods.  Additional nodes are created to support them" </dev/tty
echo

CleanUp
