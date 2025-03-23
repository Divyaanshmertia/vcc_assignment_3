#!/bin/bash

# Threshold (75%)
THRESHOLD=75

# GCP MIG details
PROJECT_ID="pdf-utility-kit"
ZONE="us-west1-a"
INSTANCE_GROUP="pdf-merge-vm-instance"

# Get current CPU usage (using `mpstat` - install sysstat if needed)
CPU_USAGE=$(mpstat 1 1 | awk '/Average:/ {print 100 - $NF}')

echo "Current CPU Usage: $CPU_USAGE%"

# Check if CPU exceeds threshold
if (( $(echo "$CPU_USAGE > $THRESHOLD" | bc -l) )); then
    echo "CPU usage exceeds $THRESHOLD%. Scaling up GCP MIG..."
    
    gcloud beta compute instance-groups managed create instance-group-1     --project=pdf-utility-kit \
    --base-instance-name=instance-group-1   \
        --template=projects/pdf-utility-kit/regions/us-west1/instanceTemplates/pdf-merge-vm \
        --size=1 \
        --zone=us-west1-b
    gcloud beta compute instance-groups managed set-autoscaling instance-group-1     --project=pdf-utility-kit  \
    --zone=us-west1-b \
        --mode=on \
        --min-num-replicas=1 \
        --max-num-replicas=5   \
        --target-cpu-utilization=0.75 \
        --cpu-utilization-predictive-method=none \
        --cool-down-period=600
    fi




