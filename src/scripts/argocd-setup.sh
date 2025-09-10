#!/bin/bash

argocd repo add git@github.com:Dynatrace-CoPilot/ai-orchestration-playground.git --ssh-private-key-path ~/.ssh/id_ed25519 --name ai-orchestration-playground
kubectl apply -n argocd -f src/argocd/projects/otel-demo-project.yaml

kubectl apply -f src/argocd/apps/cert-manager-helm-app.yaml -n argocd
argocd app sync cert-manager

kubectl apply -f src/argocd/apps/otel-operator-helm-app.yaml -n argocd
argocd app sync otel-operator

# kubectl apply -k src/otel