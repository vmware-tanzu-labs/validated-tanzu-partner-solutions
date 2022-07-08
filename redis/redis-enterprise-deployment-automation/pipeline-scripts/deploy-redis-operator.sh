#!/bin/bash

# This script deploys the Redis operator
# It is meant to be run from the pipeline

if [ -z "${1}" ] ; then
    echo "USAGE: ${0} <values.yaml>" >&2
    echo "values.yaml is a file containing the values for deploying the Redis operator"
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

kapp deploy --yes \
    --app redis-operator \
    --into-ns "${namespace}" \
    --diff-changes \
    --file <(ytt -f deployment/namespace.yaml -f "${1}") \
    --file vendor/redis/role.yaml \
    --file vendor/redis/role_binding.yaml \
    --file vendor/redis/service_account.yaml \
    --file vendor/redis/crds/rec_crd.yaml \
    --file vendor/redis/crds/redb_crd.yaml \
    --file vendor/redis/admission-service.yaml \
    --file <(ytt -f vendor/redis/operator.yaml -f overlays/set-operator-image-registry.yaml -f "${1}")
