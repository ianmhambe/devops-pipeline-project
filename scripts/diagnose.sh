#!/bin/bash

echo "🔍 Diagnosing deployment issues..."
echo ""

echo "=== Cluster Info ==="
kubectl cluster-info
echo ""

echo "=== Nodes ==="
kubectl get nodes -o wide
echo ""

echo "=== All Pods ==="
kubectl get pods --all-namespaces
echo ""

echo "=== App Pods ==="
kubectl get pods -l app=devops-app -o wide
echo ""

echo "=== Deployment Details ==="
kubectl describe deployment devops-app
echo ""

echo "=== Pod Details ==="
POD_NAME=$(kubectl get pods -l app=devops-app -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$POD_NAME" ]; then
  echo "Describing pod: $POD_NAME"
  kubectl describe pod $POD_NAME
  echo ""
  echo "=== Pod Logs ==="
  kubectl logs $POD_NAME --tail=50
else
  echo "No pods found!"
fi
echo ""

echo "=== Events ==="
kubectl get events --sort-by=.metadata.creationTimestamp | tail -20
