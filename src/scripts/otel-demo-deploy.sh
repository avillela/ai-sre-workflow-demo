#!/bin/bash

export DT_API_TOKEN=$1
export DT_OTLP_ENDPOINT=$2

# Create namespace
kubectl apply -f src/otel/namespace.yaml

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: otel-collector-secret
  namespace: otel-demo
type: Opaque
stringData:
  DT_TOKEN: $DT_API_TOKEN
  DT_ENV: $DT_OTLP_ENDPOINT
EOF

# Deploy OTel Demo App via Kustomize
kubectl apply -f src/argocd/apps/otel-demo-app.yaml -n argocd
argocd app sync otel-demo
