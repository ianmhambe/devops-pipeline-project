#!/bin/bash
set -e

echo "🚀 Starting DevOps Pipeline Setup..."

# Create Kind cluster
echo "📦 Creating Kind cluster..."
kind create cluster --config=k8s/cilium/kind-config.yaml --name=devops-cluster

# Install Cilium
echo "🔒 Installing Cilium..."
bash scripts/install-cilium.sh

# Build Docker image
echo "🐳 Building Docker image..."
cd app
docker build -t devops-demo-app:latest .
cd ..

# Load image to Kind
echo "📥 Loading image to Kind cluster..."
kind load docker-image devops-demo-app:latest --name=devops-cluster

# Apply Kubernetes manifests
echo "☸️  Deploying to Kubernetes..."
kubectl apply -f k8s/base/

# Wait for deployment
echo "⏳ Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/devops-app

# Show status
echo "✅ Deployment complete!"
echo ""
echo "📊 Current status:"
kubectl get pods
kubectl get services

echo ""
echo "🌐 Access the application:"
echo "   http://localhost:30080"

echo ""
echo "🔍 View logs:"
echo "   kubectl logs -l app=devops-app --tail=50"
