#!/bin/bash
# packing-summary.sh - Analyze node packing and suggest optimal SKU

set -e

NAMESPACE="biometric-shards"
POD_MEMORY_GI=32

echo "=========================================="
echo "Biometric Shards Packing Analysis"
echo "=========================================="
echo ""

# Get pods and their nodes
echo "1. Current pod distribution:"
echo ""
kubectl get pods -n "$NAMESPACE" -l app=biometric-shard -o wide | \
    awk 'NR==1 {print $0} NR>1 {print $1, $7, $6}' | column -t
echo ""

# Analyze nodes
echo "2. Node analysis:"
echo ""

NODES=$(kubectl get pods -n "$NAMESPACE" -l app=biometric-shard -o json | \
    jq -r '.items[].spec.nodeName' | sort -u)

if [ -z "$NODES" ]; then
    echo "   No pods scheduled yet"
    exit 0
fi

NODE_COUNT=0
TOTAL_ALLOCATABLE_MEM_GI=0
TOTAL_REQUESTED_MEM_GI=0

for NODE in $NODES; do
    NODE_COUNT=$((NODE_COUNT + 1))
    
    # Get node info
    NODE_INFO=$(kubectl get node "$NODE" -o json)
    INSTANCE_TYPE=$(echo "$NODE_INFO" | jq -r '.metadata.labels["node.kubernetes.io/instance-type"] // .metadata.labels["beta.kubernetes.io/instance-type"] // "unknown"')
    ALLOCATABLE_MEM=$(echo "$NODE_INFO" | jq -r '.status.allocatable.memory')
    
    # Convert memory to Gi (rough approximation)
    ALLOCATABLE_MEM_GI=$(echo "$ALLOCATABLE_MEM" | sed 's/Ki$//' | awk '{printf "%.1f", $1/1024/1024}')
    
    # Count pods on this node
    POD_COUNT=$(kubectl get pods -n "$NAMESPACE" -l app=biometric-shard --field-selector spec.nodeName="$NODE" --no-headers | wc -l)
    
    # Calculate requested memory
    REQUESTED_MEM_GI=$((POD_COUNT * POD_MEMORY_GI))
    
    # Calculate utilization
    UTILIZATION=$(echo "$REQUESTED_MEM_GI $ALLOCATABLE_MEM_GI" | awk '{printf "%.1f", ($1/$2)*100}')
    
    echo "Node: $NODE"
    echo "  Instance Type: $INSTANCE_TYPE"
    echo "  Allocatable Memory: ${ALLOCATABLE_MEM_GI}Gi"
    echo "  Biometric Pods: $POD_COUNT"
    echo "  Requested Memory: ${REQUESTED_MEM_GI}Gi"
    echo "  Memory Utilization: ${UTILIZATION}%"
    echo ""
    
    TOTAL_ALLOCATABLE_MEM_GI=$(echo "$TOTAL_ALLOCATABLE_MEM_GI $ALLOCATABLE_MEM_GI" | awk '{printf "%.1f", $1+$2}')
    TOTAL_REQUESTED_MEM_GI=$((TOTAL_REQUESTED_MEM_GI + REQUESTED_MEM_GI))
done

echo "=========================================="
echo "3. Summary:"
echo "   Total Nodes: $NODE_COUNT"
echo "   Total Allocatable Memory: ${TOTAL_ALLOCATABLE_MEM_GI}Gi"
echo "   Total Requested Memory: ${TOTAL_REQUESTED_MEM_GI}Gi"
echo "   Average pods per node: $(echo "10 $NODE_COUNT" | awk '{printf "%.1f", $1/$2}')"
echo ""

# Suggest optimal SKU
echo "4. SKU Recommendations:"
echo ""
echo "   Based on 10 shards @ 32Gi each (320Gi total requested):"
echo ""
echo "   Optimal configurations:"
echo "   • 3x Standard_E16s_v5  (128Gi each, 384Gi total) = ~3.3 pods/node"
echo "   • 4x Standard_E8s_v5   (64Gi each, 256Gi total)  = ~2.5 pods/node"
echo "   • 2x Standard_E20s_v5  (160Gi each, 320Gi total) = 5 pods/node"
echo "   • 2x Standard_E32s_v5  (256Gi each, 512Gi total) = 5 pods/node (over-provisioned)"
echo ""
echo "   Cost-optimized (fewer nodes):"
echo "   • 2x Standard_E20s_v5 or 2x Standard_E32s_v5"
echo ""
echo "   Balance (HA + cost):"
echo "   • 3x Standard_E16s_v5 (recommended for production)"
echo ""

# Get actual instance types used
echo "5. Current instance types in use:"
echo ""
kubectl get nodes -o json | jq -r '
  .items[] |
  select(.metadata.labels["workload"] == "biometric-explore" or 
         .metadata.labels["workload"] == "biometric-stable" or
         (.spec.taints // [] | any(.key == "biometric"))) |
  "\(.metadata.name)\t\(.metadata.labels["node.kubernetes.io/instance-type"] // .metadata.labels["beta.kubernetes.io/instance-type"] // "unknown")\t\(.status.allocatable.memory)"
' | column -t || echo "   No Karpenter-provisioned nodes found yet"

echo ""
echo "=========================================="
echo "Analysis complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Review the packing efficiency above"
echo "  2. Choose your preferred SKU from recommendations"
echo "  3. Update overlays/stable/nodepool.yaml with chosen SKU"
echo "  4. Deploy stable overlay: kubectl apply -k k8s/overlays/stable"
