#!/bin/bash

echo "🧹 Cleaning up resources..."

# Delete Kubernetes resources
echo "Deleting Kubernetes resources..."
kubectl delete -f k8s/base/ --ignore-not-found=true

# Delete Kind cluster
echo "Deleting Kind cluster..."
kind delete cluster --name=devops-cluster

# Clean up Docker images
echo "Cleaning up Docker images..."
docker rmi devops-demo-app:latest --force

echo "✅ Cleanup complete!"
