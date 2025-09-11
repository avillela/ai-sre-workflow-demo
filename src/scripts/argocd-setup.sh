#!/bin/bash

export SSH_PK_PATH=$1

## Register project repo in ArgoCD
argocd repo add git@github.com:Dynatrace-CoPilot/ai-orchestration-playground.git --ssh-private-key-path $SSH_PK_PATH --name ai-orchestration-playground

## Create ArgoCD project
kubectl apply -n argocd -f src/argocd/projects/otel-demo-project.yaml

## Deploy cert-manager and OTel Operator
kubectl apply -f src/argocd/apps/cert-manager-helm-app.yaml -n argocd
argocd app sync cert-manager

kubectl apply -f src/argocd/apps/otel-operator-helm-app.yaml -n argocd
argocd app sync otel-operator

# kubectl apply -k src/otel