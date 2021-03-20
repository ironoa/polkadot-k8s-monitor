#!/bin/bash
set -e

CURRENT_DIR=$(dirname "$0")
cd ${CURRENT_DIR}

if ! [ -f ../config/env.sh ]; then
  echo "env.sh does not exist. Use env.sample.sh as example to generate it." >&2
  exit 1
fi

if ! [ -x "$(command -v kubectl)" ]; then
  echo 'Error: kubectl is not installed.' >&2
  exit 1
fi

source ../config/env.sh
./preflight.sh

helm repo update
helmfile --environment production -f ../helmfile.pre.d sync
helmfile --environment production -f ../helmfile.d sync
