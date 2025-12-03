#!/bin/bash

echo "🔒 Running security scans..."
echo ""

# Check if directories exist
if [ ! -d "k8s" ]; then
  echo "⚠️  Warning: k8s directory not found, skipping config scan"
  K8S_EXISTS=false
else
  K8S_EXISTS=true
fi

# Scan Docker image
echo "1. Scanning Docker image for vulnerabilities..."
if docker images | grep -q "devops-demo-app"; then
  docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
    aquasec/trivy image --severity HIGH,CRITICAL devops-demo-app:latest
else
  echo "⚠️  Docker image not found, skipping image scan"
fi

echo ""

# Scan Kubernetes manifests
if [ "$K8S_EXISTS" = true ]; then
  echo "2. Scanning Kubernetes manifests..."
  docker run --rm -v "$(pwd)":/project \
    aquasec/trivy config /project/k8s/ --severity HIGH,CRITICAL || echo "⚠️  Config scan completed with warnings"
else
  echo "2. Skipping Kubernetes manifest scan (directory not found)"
fi

echo ""

# Scan filesystem for vulnerabilities
echo "3. Scanning filesystem..."
docker run --rm -v "$(pwd)":/project \
  aquasec/trivy fs /project --severity HIGH,CRITICAL --skip-dirs node_modules || echo "⚠️  Filesystem scan completed with warnings"

echo ""

# Scan for secrets (optional - can be noisy)
echo "4. Scanning for secrets in code..."
if command -v gitleaks &> /dev/null; then
  gitleaks detect --source . -v || echo "⚠️  Secret scan completed (some findings may be false positives)"
else
  echo "ℹ️  Gitleaks not installed, skipping secret scan"
  echo "   Install with: brew install gitleaks (Mac) or download from https://github.com/gitleaks/gitleaks"
fi

echo ""
echo "✅ Security scans complete!"
echo ""
echo "💡 Tips:"
echo "  - HIGH/CRITICAL issues should be fixed before production"
echo "  - Review all findings in detail"
echo "  - Update dependencies regularly: cd app && npm audit fix"