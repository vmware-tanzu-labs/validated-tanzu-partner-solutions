#!/bin/bash

# This script deploys the RedisBank sample app
# https://github.com/redis-developer/redisbank
#
# The image was built using Cloud Native Buildpacks (https://buildpacks.io/) and running:
# redisbank/ $ pack build --builder gcr.io/buildpacks/builder:v1 projects.registry.vmware.com/tanzu_isv_engineering/redisbank
#
# It is meant to be run manually, connected to the Redis cluster

if [ -z "${1}" ] ; then
    echo "USAGE: ${0} <namespace> <database-name>" >&2
    echo "namespace     - The Kubernetes namespace where the Redis Enterprise Database is deployed"
    echo "database-name - The name of the Redis Enterprise Database deployed to Kubernetes"
    exit 1
fi

namespace=$1
databaseName=$2

if [ ! -d vendor/redisbank ] ; then
    echo "Error: redis directory missing. Please run 'vendir sync'." >&2
    exit 1
fi

redisbankImage=projects.registry.vmware.com/tanzu_isv_engineering/redisbank
kapp deploy --app redisbank \
    --into-ns "${namespace}" \
    --diff-changes \
    --file <(ytt \
        -f vendor/redisbank/deploy-on-k8s.yaml \
        -f overlays/redisbank-sampleapp-image-overlay.yaml \
        -f overlays/redisbank-sampleapp-secret-name.yaml \
        -v database.name="${databaseName}" \
        -v redisbankImage="${redisbankImage}") \
    --file deployment/redisbank-svc.yaml
