#!/usr/bin/bash

CleanUp(){
    kubectl delete ns development

    kubectl delete ns staging

    kubectl delete deploy default-dep -n default
    kubectl delete svc default-svc -n default

    kubectl delete ing default-ingress-backend -n default

}

# Change to the demo folder
cd Ingress

echo "The following demo illustrates how an Ingress Controller works in Kubernetes" "Ingress Controller:" "Info"
echo

read -p "Navigate to the Ingress page"
read -p "Click on the NGinx controller IP.  Notice it shows a 404"
read -p "Next Step - Create default backend components"
kubectl apply -f default-dep.yaml -f default-svc.yaml -f default-backend.yaml -n default
echo

read -p "Next Step - Creates the development namespace"
kubectl create ns development
echo

read -p "Click Deployments - Change the Namespace dropdown to development"

read -p "Next Step - Creates all the deployments and service in development namespace"
kubectl apply -f blue-dep.yaml -f blue-svc-lb.yaml -n development
kubectl apply -f red-dep.yaml -f red-svc-lb.yaml -n development
kubectl apply -f yellow-dep.yaml -f yellow-svc-lb.yaml -n development
echo

read -p "Navigate to Ingress page"
read -p "Observe how there are 4 external IP addresses"
read -p "Next Step - Creates Ingress rules for each service"
kubectl apply -f colors-ingress.yaml -n development
echo

read -p "Verify all the rules work: http://<ip>/blue/ etc"

read -p "Next Step - Change all the other services to ClusterIP"

kubectl delete -f blue-svc-lb.yaml -f red-svc-lb.yaml -f yellow-svc-lb.yaml -n development
kubectl apply -f blue-svc-cip.yaml -f red-svc-cip.yaml -f yellow-svc-cip.yaml -n development
echo

read -p "Next Step - Creates the staging namespace"
kubectl create ns staging
echo

read -p "Next Step - Creates all the deployments and service in staging namespace"
kubectl apply -f blue-dep.yaml -f blue-svc-cip.yaml -n staging
kubectl apply -f red-dep.yaml -f red-svc-cip.yaml -n staging
kubectl apply -f yellow-dep.yaml -f yellow-svc-cip.yaml -n staging
echo

read -p "Click Deployments - Change the Namespace dropdown to staging"
read -p "Navigate to Services.  Observe all are cluster Ips"
read -p "Navigate to Ingress.  Observe there's no way to get to the services from external"
echo

read -p "Next Step - Delete ingress rule"
kubectl delete ing colors-ingress -n development
echo

read -p "Next Step - Create namespace ingress rules"
kubectl apply -f colors-ingress-development.yaml -n development
kubectl apply -f colors-ingress-staging.yaml -n staging
echo

read -p "Navigate to Ingress in both namespaces"
read -p "Verify all the rules work: http://<ip>/staging/blue/, http://<ip>/development/blue/ etc"
echo

read -p "Click on the NGinx controller IP.  Notice there's a page there now"
echo

CleanUp