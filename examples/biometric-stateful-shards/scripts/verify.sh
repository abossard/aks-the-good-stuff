#!/bin/bash
# verify.sh - Verify biometric shards deployment

set -e

NAMESPACE="biometric-shards"
EXPECTED_REPLICAS=10

echo "=========================================="
echo "Biometric Shards Verification"
echo "=========================================="
echo ""

# Check namespace
echo "1. Checking namespace..."
if kubectl get namespace "$NAMESPACE" &>/dev/null; then
    echo "   ✓ Namespace '$NAMESPACE' exists"
else
    echo "   ✗ Namespace '$NAMESPACE' not found"
    exit 1
fi
echo ""

# Check StatefulSet
echo "2. Checking StatefulSet..."
STS_NAME=$(kubectl get statefulset -n "$NAMESPACE" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -z "$STS_NAME" ]; then
    echo "   ✗ No StatefulSet found in namespace $NAMESPACE"
    exit 1
fi
echo "   ✓ StatefulSet: $STS_NAME"

READY=$(kubectl get statefulset "$STS_NAME" -n "$NAMESPACE" -o jsonpath='{.status.readyReplicas}')
DESIRED=$(kubectl get statefulset "$STS_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.replicas}')
echo "   Ready: $READY / $DESIRED"

if [ "$READY" -eq "$DESIRED" ] && [ "$DESIRED" -eq "$EXPECTED_REPLICAS" ]; then
    echo "   ✓ All $EXPECTED_REPLICAS replicas are ready"
else
    echo "   ⚠ Not all replicas are ready yet"
    kubectl get pods -n "$NAMESPACE" -l app=biometric-shard
fi
echo ""

# Check pods
echo "3. Checking pod status..."
kubectl get pods -n "$NAMESPACE" -l app=biometric-shard -o wide
echo ""

# Check services
echo "4. Checking services..."
kubectl get svc -n "$NAMESPACE"
echo ""

# Check PDB
echo "5. Checking PodDisruptionBudget..."
PDB_NAME=$(kubectl get pdb -n "$NAMESPACE" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$PDB_NAME" ]; then
    echo "   ✓ PDB: $PDB_NAME"
    kubectl get pdb "$PDB_NAME" -n "$NAMESPACE"
else
    echo "   ⚠ No PodDisruptionBudget found"
fi
echo ""

# Check DNS resolution for each shard
echo "6. Checking DNS resolution for shards..."
HEADLESS_SVC="biometric-shards.$NAMESPACE.svc.cluster.local"
echo "   Headless service: $HEADLESS_SVC"

# Get first pod name to run DNS tests from
FIRST_POD=$(kubectl get pods -n "$NAMESPACE" -l app=biometric-shard -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -n "$FIRST_POD" ]; then
    echo "   Testing DNS from pod: $FIRST_POD"
    
    # Test headless service DNS
    echo "   Testing headless service DNS..."
    if kubectl exec "$FIRST_POD" -n "$NAMESPACE" -- nslookup "$HEADLESS_SVC" &>/dev/null; then
        echo "   ✓ Headless service DNS resolves"
    else
        echo "   ⚠ Headless service DNS resolution failed"
    fi
    
    # Test individual pod DNS (first 3 only)
    for i in {0..2}; do
        POD_DNS="$STS_NAME-$i.$HEADLESS_SVC"
        if kubectl exec "$FIRST_POD" -n "$NAMESPACE" -- nslookup "$POD_DNS" &>/dev/null; then
            echo "   ✓ Pod DNS resolves: $POD_DNS"
        else
            echo "   ⚠ Pod DNS resolution failed: $POD_DNS"
        fi
    done
    echo "   (Only tested first 3 pods for brevity)"
else
    echo "   ⚠ No pods available to test DNS resolution"
fi
echo ""

# Check PVCs
echo "7. Checking PersistentVolumeClaims..."
kubectl get pvc -n "$NAMESPACE"
echo ""

# Check node placement
echo "8. Checking node placement..."
echo "   Pods per node:"
kubectl get pods -n "$NAMESPACE" -l app=biometric-shard -o json | \
    jq -r '.items[] | "\(.spec.nodeName)"' | sort | uniq -c | sort -rn
echo ""

# Check resource allocation
echo "9. Checking resource allocation..."
echo "   Memory requests per pod:"
kubectl get pods -n "$NAMESPACE" -l app=biometric-shard -o json | \
    jq -r '.items[0].spec.containers[0].resources.requests.memory' || echo "N/A"
echo "   Memory limits per pod:"
kubectl get pods -n "$NAMESPACE" -l app=biometric-shard -o json | \
    jq -r '.items[0].spec.containers[0].resources.limits.memory' || echo "N/A"
echo ""

echo "=========================================="
echo "Verification complete!"
echo "=========================================="
