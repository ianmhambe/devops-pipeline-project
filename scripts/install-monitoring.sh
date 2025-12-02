#!/bin/bash
set -e

echo "📊 Installing Prometheus & Grafana..."

# Add Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Create monitoring namespace
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Install Prometheus stack with Grafana
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set grafana.enabled=true \
  --set grafana.adminPassword=admin123 \
  --wait

echo "✅ Prometheus installed!"
echo ""
echo "Access Grafana:"
echo "  kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
echo "  Then visit: http://localhost:3000"
echo "  Username: admin"
echo "  Password: admin123"
