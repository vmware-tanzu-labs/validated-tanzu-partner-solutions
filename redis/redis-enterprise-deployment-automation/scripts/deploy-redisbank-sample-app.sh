#!/bin/bash

# This script deploys the Redisbank sample app
# It is meant to be run manually, connected to the Redis cluster

if [ -z "${1}" ] ; then
    echo "USAGE: ${0} <values.yaml>" >&2
    echo "values.yaml is a file containing the values for deploying the Redisbank sample application"
    exit 1
fi

if [ ! -f "${1}" ] ; then
    echo "Error: ${1} is not a file. Please provide a valid values file." >&2
    exit 1
fi

if [ ! -d vendor/redisbank ] ; then
    echo "Error: redis directory missing. Please run 'vendir sync'." >&2
    exit 1
fi

namespace=$(ytt --file "${1}" --data-values-inspect --output json | jq -r .namespace)
if [ -z "${namespace}" ] ; then
    echo "Error: namespace was not found in the values file" >&2
    exit 1
fi

redisbankImage=harbor-repo.vmware.com/pwall/redisbank
kapp deploy --app redisbank \
    --into-ns "${namespace}" \
    --diff-changes \
    --file <(ytt \
        -f vendor/redisbank/deploy-on-k8s.yaml \
        -f overlays/redisbank-sampleapp-image-overlay.yaml \
        -f overlays/redisbank-sampleapp-secret-name.yaml \
        -f ${1} \
        -v redisbankImage="${redisbankImage}") \
    --file deployment/redisbank-svc.yaml
