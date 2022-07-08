# Redis Enterprise Deployment Automation

## Pre-requisites

Two Kubernetes cluster:
1. A small cluster where Tekton will be deployed
2. A workload cluster where Redis will be deployed

## Prepare the values repository

1. Create a git repository
2. Create a file, `values.yaml`, in that repository with the format:

```yaml
#@data/values
---
imageRegistry: <alternative image registry> harbor-repo.vmware.com/dockerhub-proxy-cache/
namespace: redis
operator:
cluster:
  name: redis-cluster
  nodes: 3
  adminUsername: pwall@vmware.com
database:
  name: my-redis-database
  persistence: aofEverySecond
  memorySize: 100MB
  modules:
  - name: search
    version: 2.2.6
  - name: timeseries
    version: 1.4.13
license: |
  ----- LICENSE START -----
  <Redis Enterprise License Key>
  ----- LICENSE END -----
```

## Preparing the pipeline

1. Build the pipeline image

```bash
export IMAGE_NAME=harbor-repo.vmware.com/pwall/redis_automation:latest
docker build -t ${IMAGE_NAME} .
docker push ${IMAGE_NAME}
```

2. Target the Tekton cluster

```bash
export KUBECONFIG=<path/to/tekton-kubeconfig.yaml>
```

3. Save the SSH key for the values repository

```bash
./scripts/deploy-repository-secret.sh ~/.ssh/id_rsa
```

4. Create a secret with the kubeconfig.yaml file for the Redis cluster

```bash
./scripts/deploy-cluster-secret.sh "path/to/redis-kubeconfig.yaml"
```

5. Deploy the tekton pipeline and tasks

```bash
./scripts/deploy-pipeline.sh
```

6. Prep the pipeline run file

```bash
ytt -f pipeline-run-template.yaml --data-value image="harbor-repo.vmware.com/pwall/redis_automation:latest" --data-value repo="git@gitlab.eng.vmware.com:pwall/redis-values.git" > pipeline-run.yaml
```

## Run the pipeline

```bash
kubectl create -f pipeline-run.yaml
```

## Monitor progress with `tkn`

```bash
tkn tr list
tkn tr logs <TaskRun instance>
```

## Monitor progrss with the Tekton Dashboard

```bash
kubectl proxy --port=8080
```

Open in a browser: http://localhost:8080/api/v1/namespaces/tekton-pipelines/services/tekton-dashboard:http/proxy/

### On the Redis cluster
