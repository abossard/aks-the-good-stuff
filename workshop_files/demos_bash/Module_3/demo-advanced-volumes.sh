#!/usr/bin/bash
CleanUp(){

    kubectl delete deploy pvc-volume-dep
    kubectl delete pvc pvc-volume-disk

}

# Change to the demo folder
cd AdvancedVolumes

echo "Navigate to the Settings page.  Turn on Mini Pods"
echo "Navigate to the Deployments page"
echo

read -p "Next Step - Creates PVC and Deployment with 1 replica.  All will be fine"
kubectl apply -f pvc-volume-disk.yaml
kubectl apply -f pvc-volume-dep.yaml
echo

echo "Wait until the Pod is running"

read -p "Next Step - Increases workload instances.  Some will be on the same node, some on others"
kubectl scale --replicas=40 deploy/pvc-volume-dep
echo

read -p "Observe how some Pods are running while others remain pending"
read -p "Next Step - Increases workload instances again.  Some will be on the same node, some on others"
kubectl scale --replicas=9 deploy/pvc-volume-dep
echo

read -p "Observe how more Pods are running while new others remain pending"
read -p "Navigate to the Nodes page"
read -p "Explain that this behavior is the result of AccessMode=ReadWriteOnce"
echo

CleanUp