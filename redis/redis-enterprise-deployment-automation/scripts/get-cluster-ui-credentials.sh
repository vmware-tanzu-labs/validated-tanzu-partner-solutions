#!/bin/bash

# This script gets the credentials for the Redis Cluster UI
# It is meant to be run manually, connected to the Redis cluster

if [ -z "${1}" ] ; then
    echo "USAGE: ${0} <namespace> <cluster-name>" >&2
    echo "namespace    - The Kubernetes namespace where the Redis cluster is deployed"
    echo "cluster-name - The name of the Redis Cluster object deployed to Kubernetes"
    exit 1
fi

namespace=$1
clusterName=$2

set -e
username=$(kubectl -n "${namespace}" get secret "${clusterName}" -o jsonpath='{.data.username}' | base64 --decode)
password=$(kubectl -n "${namespace}" get secret "${clusterName}" -o jsonpath='{.data.password}' | base64 --decode)

echo "${clusterName} Cluster UI:"
echo "Username: ${username}"
echo "Password: ${password}"
ip=$(kubectl get svc redis-cluster-ui -n redis -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "URL: https://${ip}:8443"