#!/bin/bash

argocd login $ARGOCD_URL --username $ARGOCD_USERNAME --password $ARGOCD_PASSWORD --insecure  

argocd app delete otel-demo -y
argocd app delete otel-operator -y
argocd app delete cert-manager -y

argocd proj delete otel-demo-project
argocd repo rm git@github.com:Dynatrace-CoPilot/ai-orchestration-playground.git

kubectl delete ns otel-demo
kubectl delete ns opentelemetry-operator-system
kubectl delete ns cert-manager