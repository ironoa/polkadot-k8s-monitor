#!/bin/sh
set -e

kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.15.2/cert-manager.crds.yaml

kubectl create namespace cert-manager || true
