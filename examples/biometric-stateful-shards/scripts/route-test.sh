#!/bin/bash
# route-test.sh - Test shard routing behavior

set -e

NAMESPACE="biometric-shards"
LB_SERVICE="biometric-lb"

echo "=========================================="
echo "Biometric Shards Routing Test"
echo "=========================================="
echo ""

# Get LoadBalancer IP/hostname
echo "1. Getting LoadBalancer endpoint..."
LB_IP=$(kubectl get svc "$LB_SERVICE" -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
LB_HOSTNAME=$(kubectl get svc "$LB_SERVICE" -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")

ENDPOINT="${LB_IP:-$LB_HOSTNAME}"

if [ -z "$ENDPOINT" ]; then
    echo "   ⚠ LoadBalancer not ready yet. Using port-forward instead..."
    echo ""
    echo "   Run this in another terminal:"
    echo "   kubectl port-forward -n $NAMESPACE svc/$LB_SERVICE 8080:80"
    echo ""
    ENDPOINT="localhost:8080"
    USE_PORT_FORWARD=true
else
    echo "   ✓ LoadBalancer: $ENDPOINT"
    USE_PORT_FORWARD=false
fi
echo ""

# Function to test routing
test_route() {
    local key=$1
    local endpoint=$2
    
    if [ "$USE_PORT_FORWARD" = true ]; then
        # Test via localhost (assumes port-forward is running)
        curl -s "http://${endpoint}/" 2>/dev/null || echo "Connection failed"
    else
        # Test via LoadBalancer
        curl -s "http://${endpoint}/" 2>/dev/null || echo "Connection failed"
    fi
}

# Test multiple keys
echo "2. Testing routing with different keys:"
echo "   (Each key should route to a specific shard based on hash)"
echo ""

if [ "$USE_PORT_FORWARD" = true ]; then
    echo "   ⚠ Port-forward mode - make sure 'kubectl port-forward' is running!"
    echo ""
fi

KEYS=("user123" "user456" "user789" "session-abc" "session-def" "session-xyz" "order-001" "order-002" "order-003" "tenant-A")

for KEY in "${KEYS[@]}"; do
    echo -n "   Key: $KEY -> "
    RESPONSE=$(test_route "$KEY" "$ENDPOINT")
    
    if echo "$RESPONSE" | grep -q "Biometric Shard"; then
        SHARD=$(echo "$RESPONSE" | grep -o "biometric-shard-[0-9]" | head -1)
        echo "Shard: ${SHARD:-unknown}"
    else
        echo "Failed to get response"
    fi
done

echo ""
echo "3. Verifying all shards are reachable via headless service:"
echo ""

# Get a pod to exec from
FIRST_POD=$(kubectl get pods -n "$NAMESPACE" -l app=biometric-shard -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
STS_NAME=$(kubectl get statefulset -n "$NAMESPACE" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -n "$FIRST_POD" ] && [ -n "$STS_NAME" ]; then
    HEADLESS_SVC="biometric-shards.$NAMESPACE.svc.cluster.local"
    
    for i in {0..9}; do
        POD_NAME="$STS_NAME-$i"
        POD_DNS="$STS_NAME-$i.$HEADLESS_SVC"
        
        echo -n "   Testing $POD_NAME ($POD_DNS): "
        
        if kubectl exec "$FIRST_POD" -n "$NAMESPACE" -- curl -s -m 5 "http://${POD_DNS}:8080/" &>/dev/null; then
            echo "✓ Reachable"
        else
            echo "✗ Not reachable"
        fi
    done
else
    echo "   ⚠ No pods available for testing"
fi

echo ""
echo "=========================================="
echo "Routing test complete!"
echo "=========================================="
echo ""
echo "Expected behavior:"
echo "  • Each key should consistently route to the same shard"
echo "  • All 10 shards should be reachable via headless service"
echo "  • If any shard is down, the system is considered down"
