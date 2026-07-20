#!/bin/bash
# Sync the production stack against the current kubectl context.
#   ./deployProduction.sh              -> sync everything in helmfile.d
#   ./deployProduction.sh 60 70       -> sync only helmfile.d/60-*.yaml and 70-*.yaml
#   ./deployProduction.sh pre         -> sync helmfile.pre.d (cert-manager)
set -e

CURRENT_DIR=$(dirname "$0")
cd ${CURRENT_DIR}

for f in env.sh nodes.yaml validators.yaml; do
  if ! [ -f "../config/$f" ]; then
    echo "config/$f does not exist. Use the matching sample in config/ to generate it." >&2
    exit 1
  fi
done

if ! [ -x "$(command -v helmfile)" ]; then
  echo 'Error: helmfile is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v kubectl)" ]; then
  echo 'Error: kubectl is not installed.' >&2
  exit 1
fi

echo "kubectl context: $(kubectl config current-context)"

source ../config/env.sh

helm repo update

if [ $# -eq 0 ]; then
  helmfile --environment production -f ../helmfile.d sync
  exit 0
fi

for sel in "$@"; do
  if [ "$sel" = "pre" ]; then
    helmfile --environment production -f ../helmfile.pre.d sync
    continue
  fi
  matches=(../helmfile.d/${sel}*.yaml)
  if ! [ -e "${matches[0]}" ]; then
    echo "Error: no helmfile.d/${sel}*.yaml found." >&2
    exit 1
  fi
  for m in "${matches[@]}"; do
    helmfile --environment production -f "$m" sync
  done
done
