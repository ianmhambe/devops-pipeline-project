#!/bin/bash

echo "🔒 Quick Security Check..."
echo ""

# 1. Check Docker image if it exists
if docker images | grep -q "devops-demo-app"; then
  echo "📦 Scanning Docker image..."
  docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
    aquasec/trivy image --severity CRITICAL --quiet devops-demo-app:latest
  echo ""
fi

# 2. Check npm dependencies
if [ -f "app/package.json" ]; then
  echo "📋 Checking npm dependencies..."
  cd app
  npm audit --audit-level=moderate || true
  cd ..
  echo ""
fi

# 3. Simple file checks
echo "📄 Checking for common issues..."

# Check for exposed secrets patterns
if grep -r "password.*=.*['"].*['"]" . --exclude-dir={node_modules,.git} 2>/dev/null | head -5; then
  echo "⚠️  Found potential hardcoded passwords!"
fi

if grep -r "api.*key.*=.*['"].*['"]" . --exclude-dir={node_modules,.git} 2>/dev/null | head -5; then
  echo "⚠️  Found potential API keys!"
fi

echo ""
echo "✅ Quick security check complete!"
echo ""
echo "For detailed scan, run: ./scripts/security-scan.sh"