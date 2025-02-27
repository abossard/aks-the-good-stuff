#!/usr/bin/bash

CleanUp(){
    kubectl delete job countdown-job
    kubectl delete cronjob sample-cron-job
}

# Change to the demo folder
cd Jobs


read -p "Navigate to the Jobs page"
echo

read -p "Next Step - Creates a Job"
kubectl apply -f countdown-job.yaml
echo

read -p "Next Step - Create a Cron Job"
kubectl apply -f sample-cron-job.yaml
echo

read -p "Click on the Cron Jobs tab.  Wait for new jobs to show up.  Will maintain history of past 3 jobs"

CleanUp