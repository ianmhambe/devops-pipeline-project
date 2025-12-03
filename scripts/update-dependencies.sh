#!/bin/bash

echo "📦 Updating application dependencies..."

cd app

# Add new dependencies
npm install --save prom-client winston

# Regenerate package-lock.json
rm -f package-lock.json
npm install

echo "✅ Dependencies updated!"
echo ""
echo "Next steps:"
echo "1. Copy the new server.js code"
echo "2. Run: docker build -t devops-demo-app:latest ."
echo "3. Run: kind load docker-image devops-demo-app:latest --name=devops-cluster"
echo "4. Run: kubectl rollout restart deployment/devops-app"
