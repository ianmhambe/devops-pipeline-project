#!/bin/bash
set -e

echo "🚀 Setting up ADVANCED DevOps Pipeline..."
echo "This will install:"
echo "  ✅ Prometheus & Grafana (Monitoring)"
echo "  ✅ EFK Stack (Logging)"
echo "  ✅ Metrics Server (Autoscaling)"
echo "  ✅ Horizontal Pod Autoscaler"
echo "  ✅ Security Scanning"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Step 1: Setup base cluster
echo ""
echo "📦 Step 1/6: Setting up base cluster..."
if ! kind get clusters 2>/dev/null | grep -q "devops-cluster"; then
  bash scripts/setup.sh
fi

# Step 2: Install Helm
echo ""
echo "⎈ Step 2/6: Installing Helm..."
if ! command -v helm &> /dev/null; then
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# Step 3: Install Monitoring
echo ""
echo "📊 Step 3/6: Installing Prometheus & Grafana..."
bash scripts/install-monitoring.sh

# Step 4: Install Metrics Server for HPA
echo ""
echo "📈 Step 4/6: Installing Metrics Server..."
bash scripts/install-metrics-server.sh

# Step 5: Update app with metrics
echo ""
echo "🔄 Step 5/6: Updating application with monitoring..."
cd app
npm install prom-client winston
cd ..

# Rebuild and redeploy
docker build -t devops-demo-app:latest ./app
kind load docker-image devops-demo-app:latest --name=devops-cluster

# Apply HPA
kubectl apply -f k8s/autoscaling/hpa.yaml

# Step 6: Security scan
echo ""
echo "🔒 Step 6/6: Running security scan..."
bash scripts/security-scan.sh || true

echo ""
echo "✅✅✅ ADVANCED SETUP COMPLETE! ✅✅✅"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 ACCESS YOUR TOOLS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Application:"
echo "   kubectl port-forward svc/devops-app-service 8080:80"
echo "   → http://localhost:8080"
echo ""
echo "2. Grafana (Monitoring):"
echo "   kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
echo "   → http://localhost:3000 (admin/admin123)"
echo ""
echo "3. Prometheus:"
echo "   kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090"
echo "   → http://localhost:9090"
echo ""
echo "4. Check Autoscaling:"
echo "   kubectl get hpa -w"
echo "   kubectl top pods"
echo ""
echo "5. View Metrics:"
echo "   kubectl port-forward svc/devops-app-service 8080:80"
echo "   → http://localhost:8080/metrics"
echo ""
echo "6. Run Load Test:"
echo "   bash scripts/load-test.sh"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
