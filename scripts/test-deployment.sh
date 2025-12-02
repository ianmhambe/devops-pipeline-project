#!/bin/bash

echo "🧪 Testing deployment..."

# Check if pods are running
echo "Checking pods..."
kubectl get pods -l app=devops-app

# Test application endpoint
echo ""
echo "Testing application endpoint..."
kubectl port-forward service/devops-app-service 8080:80 &
PF_PID=$!
sleep 3

curl -s http://localhost:8080 | jq .

kill $PF_PID

echo ""
echo "✅ Tests complete!"
