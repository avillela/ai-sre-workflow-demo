#!/bin/bash

# Create port forward for ArgoCD
nohup kubectl port-forward svc/argocd-server -n argocd 9080:443 > portforward.log 2>&1 &