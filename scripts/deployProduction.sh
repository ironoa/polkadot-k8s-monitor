#!/bin/bash
set -e

CURRENT_DIR=$(dirname "$0")
cd ${CURRENT_DIR}

if ! [ -f ../config/env.sh ]; then
  echo "env.sh does not exist. Use env.sample.sh as example to generate it." >&2
  exit 1
fi

if ! [ -f ../config/nodes.yaml ]; then
  echo "nodes.yaml does not exist. Use nodes.sample.yaml as example to generate it." >&2
  exit 1
fi

if ! [ -x "$(command -v helmfile)" ]; then
  echo 'Error: helmfile is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v kubectl)" ]; then
  echo 'Error: kubectl is not installed.' >&2
  exit 1
fi

source ../config/env.sh

helm repo update
helmfile --environment production -f ../helmfile.pre.d sync
helmfile --environment production -f ../helmfile.d sync