#!/bin/bash
set -e

echo "📊 Installing Metrics Server..."

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

echo "🔧 Patching Metrics Server for Kind..."

kubectl patch deployment metrics-server -n kube-system --type='json' \
  -p='[
    {"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"},
    {"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-preferred-address-types=InternalIP,Hostname"}
  ]'

echo "⏳ Restarting Metrics Server..."
kubectl delete pod -n kube-system -l k8s-app=metrics-server

echo "⏳ Waiting for Metrics Server..."
kubectl wait --for=condition=ready pod -l k8s-app=metrics-server -n kube-system --timeout=180s

echo "✅ Metrics Server installed successfully!"
