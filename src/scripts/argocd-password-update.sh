#!/bin/bash

ARGOCD_BASE_URL=$1
ARGOCD_USERNAME=$2
ARGOCD_PASSWORD=$3
ARGOCD_TMP_ADMIN_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode)

echo "Password: $ARGOCD_PASSWORD"
echo "Username: $ARGOCD_USERNAME"
echo "Temp admin password: $ARGOCD_TMP_ADMIN_PASSWORD"
echo "Base URL: $ARGOCD_BASE_URL"

# Log into ArgoCD with temp password
argocd login $ARGOCD_BASE_URL --username $ARGOCD_USERNAME --password $ARGOCD_TMP_ADMIN_PASSWORD --insecure

# Change the password
argocd account update-password --current-password $ARGOCD_TMP_ADMIN_PASSWORD --new-password $ARGOCD_PASSWORD

# curl -X POST https://$ARGOCD_BASE_URL/api/v1/session \
#   -k \
#   -H "Content-Type: application/json" \
#   -d "{\"username\":\"admin\",\"password\":\"$ARGOCD_PASSWORD\"}"


# Enable apiKey capability for admin account, restart ArgoCD server, and re-start port forward.
# kubectl patch configmap argocd-cm \
#   -n argocd \
#   --type merge \
#   -p '{"data": {"accounts.admin": "apiKey"}}'

# kubectl -n argocd rollout restart deployment argocd-server

# ./src/scripts/port-forward.sh

# # Generate ArgoCD API token
# ARGOCD_API_TOKEN=$(argocd account generate-token)
# cp src/goose/config/.env /tmp/.env
# sed -i "s/<argocd_api_token>/$ARGOCD_API_TOKEN/g" /tmp/.env
# cp /tmp/.env src/goose/config/.env