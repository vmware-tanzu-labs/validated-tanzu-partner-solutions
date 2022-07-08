#!/bin/bash

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

if [ ! -d vendor/redis ] ; then
    echo "Error: redis directory missing. Please run 'vendir sync'." >&2
    exit 1
fi

namespace=$(ytt --file "${1}" --data-values-inspect --output json | jq -r .namespace)
if [ -z "${namespace}" ] ; then
    echo "Error: namespace was not found in the values file" >&2
    exit 1
fi

clusterName=$(ytt --file "${1}" --data-values-inspect --output json | jq -r .cluster.name)
if [ -z "${clusterName}" ] ; then
    echo "Error: cluster.name was not found in the values file" >&2
    exit 1
fi

kapp deploy --yes --app "${clusterName}" \
    --into-ns "${namespace}" \
    --diff-changes \
    --file <(ytt --file deployment/cluster.yaml --file "${1}" --file overlays/set-cluster-image-registry.yaml)

function clusterIsReady {
    state=$(kubectl -n "${namespace}" get "rec/${clusterName}" --output=jsonpath='{.status.state}')
    test "$state" = "Running"
}

echo "waiting for ${clusterName} to become ready"
sleepPeriod=5
let "limit=3600/${sleepPeriod}"
until clusterIsReady; do
    sleep ${sleepPeriod}
    echo -n "."
    let "limit--"
    if [ $limit -eq 0 ]; then
        echo "${clusterName} never became ready in 1 hour..."
        exit 1
    fi
done
