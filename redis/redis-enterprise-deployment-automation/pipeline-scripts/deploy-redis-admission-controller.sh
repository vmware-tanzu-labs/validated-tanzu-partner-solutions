#!/bin/bash

# Copyright 2022 VMware, Inc.
# SPDX-License-Identifier: MIT

# This script deploys the Redis admission controller
# It is meant to be run from the pipeline

if [ -z "${1}" ] ; then
    echo "USAGE: ${0} <values.yaml>" >&2
    echo "values.yaml is a file containing the values for deploying the Redis admission controller"
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

cert=$(kubectl get secret admission-tls -n "${namespace}" -o jsonpath='{.data.cert}')

kapp deploy --yes --app redis-admission-controller \
    --into-ns "${namespace}" \
    --diff-changes \
    --file <(ytt --file vendor/redis/admission/webhook.yaml --data-value cert="${cert}" --data-value namespace="${namespace}" --file overlays/update-admission-controller.yaml)
