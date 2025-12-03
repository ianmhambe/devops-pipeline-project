#!/bin/bash
set -e

echo "📝 Installing EFK Stack (Elasticsearch, Fluentd, Kibana)..."

# Create logging namespace
kubectl create namespace logging --dry-run=client -o yaml | kubectl apply -f -

# Add Elastic Helm repo
helm repo add elastic https://helm.elastic.co
helm repo update

# Install Elasticsearch
echo "Installing Elasticsearch..."
helm upgrade --install elasticsearch elastic/elasticsearch \
  --namespace logging \
  --set replicas=1 \
  --set resources.requests.memory=1Gi \
  --set resources.limits.memory=2Gi \
  --wait

# Install Kibana
echo "Installing Kibana..."
helm upgrade --install kibana elastic/kibana \
  --namespace logging \
  --wait

# Install Fluentd
echo "Installing Fluentd..."
kubectl apply -f k8s/logging/fluentd.yaml

echo "✅ EFK Stack installed!"
echo ""
echo "Access Kibana:"
echo "  kubectl port-forward -n logging svc/kibana-kibana 5601:5601"
echo "  Then visit: http://localhost:5601"
