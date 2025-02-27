#!/usr/bin/bash


CleanUp(){
    kubectl delete deploy workload-1-ephemeral workload-3-dynamic-file
    kubectl delete deploy workload-2-disk
    kubectl delete cm configmap-file
    kubectl delete secret secret-simple
    kubectl delete pvc dynamic-file-storage-pvc
}


# Change to the demo folder
cd volumes

read -p "Navigate to the Namespace"
echo

read -p "Next Step - Create initial workload with ephemeral volumes"
kubectl apply -f configmap-file.yaml 
kubectl apply -f secret-simple.yaml
kubectl apply -f workload-1-ephemeral.yaml
echo

read -p "Enter the Disk Name of the Azure Disk (make sure the cluster identity has rights to disk): " AzureDiskName
echo $AzureDiskName
echo

read -p "Enter the Resource ID of the Azure Disk: " AzureDiskUri
echo $AzureDiskUri
echo


if  test -n $AzureDiskName &&  test -n $AzureDiskUri ; then
echo 'creating temp yaml file and replacing values'
echo

cp workload-2-disk.yaml temp-disk.yaml
sed -i -e s/AZURE_DISK_NAME/$AzureDiskName/g temp-disk.yaml
sed -i -e s/AZURE_DISK_URI/$AzureDiskUri/g temp-disk.yaml
read -p 'Replaced Azure disk and URI values'
echo

read -p "Next Step - Create deployment with Azure Disk Volume"
kubectl apply -f temp-disk.yaml
rm temp-disk.yaml

else
read -p 'Skipping static disk'
echo
fi

read -p "Next Step - Create deployment with Dynamic Azure File Volume"
kubectl apply -f pvc-dynamic-file.yaml
kubectl apply -f workload-3-dynamic-file.yaml
echo

CleanUp