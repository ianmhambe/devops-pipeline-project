#!/bin/bash
set -e

echo "⎈ Deploying with Helm..."

# Install or upgrade the chart
helm upgrade --install devops-app ./helm/devops-app \
  --namespace default \
  --create-namespace \
  --wait

echo "✅ Deployment complete!"
echo ""
echo "Check status:"
echo "  helm list"
echo "  kubectl get pods"
echo ""
echo "Upgrade with new values:"
echo "  helm upgrade devops-app ./helm/devops-app --set replicaCount=5"
