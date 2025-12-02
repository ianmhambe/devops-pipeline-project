#!/bin/bash
set -e

echo "🔒 Running security scans..."
echo ""

# Scan Docker image
echo "1. Scanning Docker image for vulnerabilities..."
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image devops-demo-app:latest

echo ""
echo "2. Scanning Kubernetes manifests..."
docker run --rm -v "$(pwd)":/project \
  aquasec/trivy config /project/k8s/

echo ""
echo "3. Scanning for secrets in code..."
docker run --rm -v "$(pwd)":/path \
  zricethezav/gitleaks:latest detect --source /path -v

echo ""
echo "✅ Security scans complete!"
