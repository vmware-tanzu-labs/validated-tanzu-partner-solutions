#!/bin/bash

# Copyright 2022 VMware, Inc.
# SPDX-License-Identifier: MIT

# This script deploys a secret with the SSH key required to pull the values repository
# It is meant to be run manually, connected to the pipeline cluster

PRIVATE_KEY_FILE=$1
if [ ! -f "${PRIVATE_KEY_FILE}" ]; then
    echo "Error: invalid private key file."
    echo "USAGE: deploy-repository-secret.sh ~/.ssh/id_rsa"
    exit 1
fi

kubectl apply -f <(kubectl create secret generic values-repository-secret --from-file id_rsa="${PRIVATE_KEY_FILE}" -o yaml --dry-run=client)
