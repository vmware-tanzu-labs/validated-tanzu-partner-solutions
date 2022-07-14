#!/bin/bash

# Copyright 2022 VMware, Inc.
# SPDX-License-Identifier: MIT

# This script deploys the Tekton pipeline to enable deployment automation for Redis
# It is meant to be run manually, connected to the pipeline cluster

function usage() {
    echo "USAGE: ${0} <pipeline image> <values repository>" >&2
    echo "pipeline image is the container image built from this repository" >&2
    echo "values repository is the git repository that contains the values file" >&2
    echo "" >&2
    echo "example: ${0} petewall/redis_automation git@gitlab.eng.vmware.com:pwall/redis-values.git"
    exit 1
}

if [ -z "${1}" ]; then
    echo "Error. Missing pipeline image. Please provide a valid pipeline image." >&2
    usage
fi

if [ -z "${2}" ]; then
    echo "Error. Missing values repository. Please provide a valid values repository path." >&2
    usage
fi

ytt --file pipeline-run-template.yaml \
    -data-value pipeline_image="$1" \
    -data-value values_repo_url="$2" > pipeline-run.yaml
kubectl create -f pipeline-run.yaml
