#!/usr/bin/bash

CleanUp(){
    kubectl delete deploy -l app=demo
    kubectl delete limitrange -l app=demo
    kubectl delete resourcequota -l app=demo
}

# Change to the demo folder
cd Resources


read -p "Navigate to the Settings page"
read -p "Turn off Mini/Micro Pods so Full sized pods are shown"
read -p "Turn ON Show Pod Resources"
read -p "Navigate to the Namespace page"
echo

read -p "Next Step - Creates initial workloads"
kubectl apply -f workload1-dep.yaml -f workload2-dep.yaml -f workload3-dep.yaml -f workload4-dep.yaml
echo

read -p "Notice there are no requests or limits defined for any of the Pods"
echo

read -p "Next Step - Creates Limit Ranges"
kubectl apply -f namespace-limit-range.yaml
echo

read -p "Notice existing Pods are not changed.  You have to recreate them"
read -p "Next Step - Update the images to force the Pods to be created"
kubectl set image deploy workload1-dep nginx=nginx:1.18
kubectl set image deploy workload2-dep nginx=nginx:1.18
kubectl set image deploy workload3-dep nginx=nginx:1.18
kubectl set image deploy workload4-dep nginx=nginx:1.18
echo

read -p "Notice new Pods have requests and limits"
read -p "Next Step - Create Resource Quotas"
kubectl apply -f namespace-resource-quotas.yaml
echo

read -p "Next Step - Update the images to force the Pods to be created"
kubectl set image deploy workload1-dep nginx=nginx:1.19
kubectl set image deploy workload2-dep nginx=nginx:1.19
kubectl set image deploy workload3-dep nginx=nginx:1.19
kubectl set image deploy workload4-dep nginx=nginx:1.19
echo

read -p "Notice nothing is being upgraded/replaced.  Examine the events of the ReplicaSet.  Notice memory limits are being exceeded"
echo

read -p "Next Step - Raise the Resource Quota slightly"
kubectl apply -f namespace-resource-quotas-slight.yaml
echo

read -p "Wait a minute or two.  Notice how some of the Pods are being upgraded individually"
read -p "1-2 Pods will continue to be replaced as the ReplicaSets notice there's now some room available"
read -p "Notice some Pod have exceeded Quota Pods count.  Toggle between Namespace and Deployments pages to see progress"
read -p "Eventually all the Pods will be upgraded, but it will take some time"
echo

read -p "Next Step - Raise the Resource Quota to double the original values"
kubectl apply -f namespace-resource-quotas-double.yaml
echo

read -p "Next Step - Update the images to force the Pods to be created"
kubectl set image deploy workload1-dep nginx=nginx:1.20
kubectl set image deploy workload2-dep nginx=nginx:1.20
kubectl set image deploy workload3-dep nginx=nginx:1.20
kubectl set image deploy workload4-dep nginx=nginx:1.20
echo

read -p "Notice how everyting is upgraded/replaced at the same time, because there's plenty of room for old and new Pods"
echo

CleanUp