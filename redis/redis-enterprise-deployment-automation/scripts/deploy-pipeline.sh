#!/bin/bash

# Copyright 2022 VMware, Inc.
# SPDX-License-Identifier: MIT

# This script deploys the Tekton pipeline to enable deployment automation for Redis
# It is meant to be run manually, connected to the pipeline cluster

# From: https://hub.tekton.dev/tekton/task/git-clone
GIT_CLONE_TASK=https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.6/git-clone.yaml
PIPELINE_FILES=$(ls pipelines/*.yaml)
TASK_FILES=$(ls tasks/*.yaml)

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
"${SCRIPT_DIR}/launch.sh" --deploy-dashboard "${GIT_CLONE_TASK}" ${PIPELINE_FILES} ${TASK_FILES}
