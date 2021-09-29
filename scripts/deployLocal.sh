#!/bin/bash
set -e

CURRENT_DIR=$(dirname "$0")
cd ${CURRENT_DIR}

CLUSTER_NAME="monitoring"

if ! [ -f ../config/env.sh ]; then
  echo "env.sh does not exist. Use env.sample.sh as example to generate it." >&2
  exit 1
fi

if ! [ -f ../config/nodes.yaml ]; then
  echo "nodes.yaml does not exist. Use nodes.sample.yaml as example to generate it." >&2
  exit 1
fi

if ! [ -x "$(command -v kubectl)" ]; then
  echo 'Error: kubectl is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v helmfile)" ]; then
  echo 'Error: helmfile is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v kind)" ]; then
  echo 'Error: kind is not installed.' >&2
  exit 1
fi

source ../config/env.sh

if [ -z $(kind get clusters | grep "^$CLUSTER_NAME$") ]; then
  kind create cluster --name $CLUSTER_NAME
fi

helm repo update
helmfile --environment "local" -f ../helmfile.d sync
