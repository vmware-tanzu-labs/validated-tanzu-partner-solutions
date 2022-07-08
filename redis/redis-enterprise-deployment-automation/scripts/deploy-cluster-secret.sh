#!/bin/bash

# This script creates a secret with the kubeconfig file to provide access to another cluster
# It is meant to be run manually, connected to the pipeline cluster

kubeconfigFile=$1
if [ ! -f "${kubeconfigFile}" ]; then
    echo "Error: invalid kubeconfig file."
    echo "USAGE: deploy-cluster-secret.sh /path/to/kubeconfig.yaml"
    exit 1
fi

kubectl apply -f <(kubectl create secret generic target-cluster --from-file kubeconfig.yaml="${kubeconfigFile}" -o yaml --dry-run=client)
