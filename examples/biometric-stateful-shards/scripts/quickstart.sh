#!/bin/bash
# quickstart.sh - Quick deployment guide for biometric-stateful-shards

set -e

echo "=========================================="
echo "Biometric Stateful Shards - Quick Start"
echo "=========================================="
echo ""

NAMESPACE="biometric-shards"

# Function to check if namespace exists
namespace_exists() {
    kubectl get namespace "$NAMESPACE" &>/dev/null
}

# Function to check deployment status
check_deployment() {
    local phase=$1
    local sts_name="${phase}-biometric-shard"
    
    echo "Checking ${phase} deployment..."
    if kubectl get statefulset "$sts_name" -n "$NAMESPACE" &>/dev/null; then
        local ready=$(kubectl get statefulset "$sts_name" -n "$NAMESPACE" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
        local desired=$(kubectl get statefulset "$sts_name" -n "$NAMESPACE" -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "0")
        echo "  Status: $ready/$desired replicas ready"
        return 0
    else
        echo "  Status: Not deployed"
        return 1
    fi
}

echo "Current Status:"
echo "---------------"
if namespace_exists; then
    echo "Namespace: $NAMESPACE exists"
    echo ""
    check_deployment "explore" || true
    check_deployment "stable" || true
else
    echo "Namespace: $NAMESPACE does not exist"
    echo "Status: Nothing deployed yet"
fi
echo ""

# Show menu
echo "=========================================="
echo "What would you like to do?"
echo "=========================================="
echo ""
echo "PHASE 1 - EXPLORE (SKU Optimization):"
echo "  1) Deploy explore overlay"
echo "  2) Verify deployment"
echo "  3) Test routing"
echo "  4) Analyze packing & costs"
echo ""
echo "PHASE 2 - STABLE (Production):"
echo "  5) Delete explore deployment"
echo "  6) Deploy stable overlay"
echo "  7) Verify stable deployment"
echo ""
echo "CLEANUP:"
echo "  8) Delete stable deployment"
echo "  9) Delete everything (including PVCs)"
echo ""
echo "  0) Exit"
echo ""
read -p "Enter your choice [0-9]: " choice

case $choice in
    1)
        echo ""
        echo "Deploying explore overlay..."
        kubectl apply -k k8s/overlays/explore
        echo ""
        echo "✓ Deployed! Watch progress with:"
        echo "  kubectl get pods -n $NAMESPACE -w"
        echo ""
        echo "Monitor Karpenter events:"
        echo "  kubectl get events -A --field-selector source=karpenter -w"
        ;;
    2)
        echo ""
        echo "Running verification script..."
        ./scripts/verify.sh
        ;;
    3)
        echo ""
        echo "Running routing test..."
        ./scripts/route-test.sh
        ;;
    4)
        echo ""
        echo "Running packing analysis..."
        ./scripts/packing-summary.sh
        echo ""
        echo "To observe costs in real-time, install and run aks-node-viewer:"
        echo "  # Install (if not already)"
        echo "  wget https://github.com/Azure/aks-node-viewer/releases/latest/download/aks-node-viewer_linux_amd64.tar.gz"
        echo "  tar -xzf aks-node-viewer_linux_amd64.tar.gz"
        echo "  sudo mv aks-node-viewer /usr/local/bin/"
        echo ""
        echo "  # Run"
        echo "  aks-node-viewer"
        ;;
    5)
        echo ""
        read -p "Are you sure you want to delete the explore deployment? (y/N): " confirm
        if [[ $confirm == [yY] ]]; then
            echo "Deleting explore deployment..."
            kubectl delete -k k8s/overlays/explore
            echo ""
            echo "✓ Explore deployment deleted"
            echo "Note: PVCs are retained and will be reused by stable deployment"
        else
            echo "Cancelled"
        fi
        ;;
    6)
        echo ""
        echo "⚠ IMPORTANT: Before deploying stable overlay:"
        echo "  1. Review packing analysis from explore phase"
        echo "  2. Update k8s/overlays/stable/nodepool.yaml with your chosen SKU"
        echo "  3. Current SKU in stable overlay: Standard_E16s_v5"
        echo ""
        read -p "Continue with deployment? (y/N): " confirm
        if [[ $confirm == [yY] ]]; then
            echo "Deploying stable overlay..."
            kubectl apply -k k8s/overlays/stable
            echo ""
            echo "✓ Deployed! Watch progress with:"
            echo "  kubectl get pods -n $NAMESPACE -w"
        else
            echo "Cancelled"
        fi
        ;;
    7)
        echo ""
        echo "Running verification script for stable deployment..."
        ./scripts/verify.sh
        echo ""
        echo "Checking disruption protection..."
        kubectl get pdb -n "$NAMESPACE"
        echo ""
        kubectl get nodes -l workload=biometric-stable -o json | \
          jq -r '.items[] | "\nNode: \(.metadata.name)\nInstance Type: \(.metadata.labels["node.kubernetes.io/instance-type"])\nTaints: \(.spec.taints)"'
        ;;
    8)
        echo ""
        read -p "Are you sure you want to delete the stable deployment? (y/N): " confirm
        if [[ $confirm == [yY] ]]; then
            echo "Deleting stable deployment..."
            kubectl delete -k k8s/overlays/stable
            echo ""
            echo "✓ Stable deployment deleted"
            echo "Note: PVCs are retained. Delete them separately if needed:"
            echo "  kubectl delete pvc -l app=biometric-shard -n $NAMESPACE"
        else
            echo "Cancelled"
        fi
        ;;
    9)
        echo ""
        echo "⚠ WARNING: This will delete EVERYTHING including persistent data!"
        read -p "Are you ABSOLUTELY sure? (type 'yes' to confirm): " confirm
        if [[ $confirm == "yes" ]]; then
            echo "Deleting everything..."
            
            # Try to delete both overlays
            kubectl delete -k k8s/overlays/stable 2>/dev/null || true
            kubectl delete -k k8s/overlays/explore 2>/dev/null || true
            
            # Delete PVCs
            kubectl delete pvc -l app=biometric-shard -n "$NAMESPACE" 2>/dev/null || true
            
            # Delete namespace
            kubectl delete namespace "$NAMESPACE" 2>/dev/null || true
            
            echo ""
            echo "✓ Everything deleted"
            echo "Karpenter will automatically deprovision nodes when they're empty"
        else
            echo "Cancelled"
        fi
        ;;
    0)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "For more information, see README.md"
echo "=========================================="
