#!/bin/bash

# This script deploys a Redis database
# It is meant to be run from the pipeline

if [ -z "${1}" ] ; then
    echo "USAGE: ${0} <values.yaml>" >&2
    echo "values.yaml is a file containing the values for deploying the Redis database"
    exit 1
fi

if [ ! -f "${1}" ] ; then
    echo "Error: ${1} is not a file. Please provide a valid values file." >&2
    exit 1
fi

if [ ! -d vendor/redis ] ; then
    echo "Error: redis directory missing. Please run 'vendir sync'." >&2
    exit 1
fi

namespace=$(ytt --file "${1}" --data-values-inspect --output json | jq -r .namespace)
if [ -z "${namespace}" ] ; then
    echo "Error: namespace was not found in the values file" >&2
    exit 1
fi

kapp deploy --yes --app redis-database \
    --into-ns "${namespace}" \
    --diff-changes \
    --file <(ytt --file deployment/database.yaml --file "${1}")
