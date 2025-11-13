#!/bin/bash

gcloud auth login
gcloud config set project ${GCP_PROJECT_NAME}
gcloud auth application-default login

# Create GKE cluster
gcloud container clusters create "${GKE_CLUSTER_NAME}" \
  --zone ${GCP_ZONE} \
  --machine-type=${GKE_MACHINE_TYPE} \
  --num-nodes=${GKE_NUM_NODES} \
  --monitoring=NONE --logging=NONE
