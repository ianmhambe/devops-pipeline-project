#!/bin/bash

echo "🔥 Running load test to trigger autoscaling..."
echo "Watch in another terminal: kubectl get hpa -w"
echo ""

# Start port-forward in background
kubectl port-forward service/devops-app-service 8080:80 > /dev/null 2>&1 &
PF_PID=$!
sleep 2

echo "Generating load for 2 minutes..."
echo "This will create many requests to trigger CPU usage"
echo ""

# Use Apache Bench or simple curl loop
if command -v ab &> /dev/null; then
  ab -n 10000 -c 50 http://localhost:8080/
else
  echo "Installing siege for load testing..."
  # Fallback to curl loop
  for i in {1..1000}; do
    curl -s http://localhost:8080/ > /dev/null &
  done
  wait
fi

kill $PF_PID 2>/dev/null

echo ""
echo "✅ Load test complete!"
echo "Check scaling:"
echo "  kubectl get hpa"
echo "  kubectl get pods"
