#!/usr/bin/bash

CleanUp(){
    kubectl delete -f .
}

# Change to the demo folder
cd KEDA-RabbitMQ


read -p "Navigate to the Settings page"
read -p "Turn ON Micro Pods"
read -p "Navigate to the Deployments page"
echo

read -p "Next Step - Creates initial workloads"
kubectl apply -f rabbit-cm.yaml
kubectl apply -f rabbit-dep.yaml
kubectl apply -f rabbit-svc.yaml
kubectl apply -f queue-processor.yaml
echo

read -p "Wait until Rabbit workload is ready"
echo

read -p "Load rabbit UI - In a background job"
read -p  " run in another window kubectl port-forward svc/rabbit-svc 15672 "
echo

read -p "Open a browser window and navigate to http://localhost:15672"
read -p "Observer SampleQueue on the Queues page"
echo

read -p "Next Step - Loads Messages into queue"
kubectl apply -f queue-loader-job.yaml
echo

read -p "Observer about 500 message in SampleQueue on the Queues page"
read -p "Observer how slowly they're being processed"
echo

read -p "Next Step - Creates KEDA autoscaler"
kubectl apply -f keda-rabbit.yaml
echo

read -p "Observer increase in pod replicas.  Show HPA Info (i) panel.  Observe Scale Down Stabilization Window"
read -p "Observer pod replica decrease as queued messages decrease"
echo

CleanUp