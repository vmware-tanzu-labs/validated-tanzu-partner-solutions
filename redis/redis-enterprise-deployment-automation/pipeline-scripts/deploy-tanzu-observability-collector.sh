#!/bin/bash

# Copyright 2022 VMware, Inc.
# SPDX-License-Identifier: MIT

# This script deploys the Redis cluster
# It is meant to be run from the pipeline

if [ -z "${1}" ] ; then
    echo "USAGE: ${0} <values.yaml>" >&2
    echo "values.yaml is a file containing the values for deploying the Redis cluster"
    exit 1
fi

if [ ! -f "${1}" ] ; then
    echo "Error: ${1} is not a file. Please provide a valid values file." >&2
    exit 1
fi

namespace=$(ytt --file "${1}" --data-values-inspect --output json | jq -r .namespace)
if [ -z "${namespace}" ] ; then
    echo "Error: namespace was not found in the values file" >&2
    exit 1
fi

databaseName=$(ytt --file "${1}" --data-values-inspect --output json | jq -r .database.name)
if [ -z "${databaseName}" ] ; then
    echo "Error: database.name was not found in the values file" >&2
    exit 1
fi

serviceName=$(kubectl -n "${namespace}" get secret "redb-${databaseName}" -o jsonpath='{.data.service_name}' | base64 --decode)
password=$(kubectl -n "${namespace}" get secret "redb-${databaseName}" -o jsonpath='{.data.password}' | base64 --decode)
port=$(kubectl -n "${namespace}" get secret "redb-${databaseName}" -o jsonpath='{.data.port}' | base64 --decode)

kubectl apply -f <(ytt \
    --file deployment/tanzu-observability-redis-collector-secret.yaml \
    --file "${1}" \
    --data-value database.host="${serviceName}" \
    --data-value database.password="${password}" \
    --data-value database.port="${port}")
