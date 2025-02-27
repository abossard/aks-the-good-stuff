#!/usr/bin/bash

CleanUp() {
    
    # SendMessageToCI "kubectl delete deploy blue-dep" "Kubectl command:" "Command"
    kubectl delete deploy blue-dep
    # SendMessageToCI "kubectl delete deploy green-dep" "Kubectl command:" "Command"
    kubectl delete deploy green-dep
    # SendMessageToCI "kubectl delete svc/staging-svc svc/production-svc" "Kubectl command:" "Command"
    kubectl delete svc/production-svc
    exit 
}

# Can test service in cluster (in a separate pod)
# while sleep 1;do curl -s http://production-svc:8080 | grep -i "POD IP:"; done
# Can test service from public IP
# while sleep 1;do curl -s http://52.191.226.207:8080 | grep -i "POD IP:"; done

# Change to the demo folder
cd BlueGreenDeployments/



read -p  "Next Step - Creates initial blue workload and service"
# # SendMessageToCI "kubectl apply -f blue-dep.yaml" "Kubectl command:" "Command"
kubectl apply -f blue-dep.yaml
# SendMessageToCI "kubectl apply -f production-svc-blue.yaml" "Kubectl command:" "Command"
# SendMessageToCI "selector:\n  target: blue-dep" "Original Service YAML:" "Code"
kubectl apply -f production-svc-blue.yaml
echo

read -p  "Open the Services page"
read -p  "Wait until the load balancer is created then open a browser to the external IP/port"
read -p  "Notice the Blue image"
read -p  "Keep the browser page open"
echo

read -p  "Next Step - Creates new green workload"
# SendMessageToCI "kubectl apply -f green-dep.yaml" "Kubectl command:" "Command"
kubectl apply -f green-dep.yaml
echo 

read -p  "Next Step - Switches the service to new workload"
# SendMessageToCI "selector:\n  target: green-dep" "Service YAML Changes:" "Code"
kubectl apply -f production-svc-green.yaml
echo

read -p  "Open to the external IP/Port browser page.  "
read -p  "Notice the image is still blue (allowing the current session to end)"
read -p  "Open a different browser (like Firefox) and go to the external IP/Port page"
read -p  "Notice the green image"

read -p  "Next Step - Deletes blue workload"
# SendMessageToCI "kubectl delete deploy blue-dep" "Kubectl command:" "Command"
kubectl delete deploy blue-dep

CleanUp