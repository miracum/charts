#!/bin/bash

# via https://github.com/argoproj/argo-helm/blob/main/scripts/renovate-bump-version.sh

depName="${1}"
if [ -z "${depName}" ]; then
  echo "Missing argument 'depName'" >&2
  exit 1
fi

newVersion="${2}"
if [ -z "${newVersion}" ]; then
  echo "Missing argument 'newVersion'" >&2
  exit 1
fi

echo "Changed dep name is: $depName to $newVersion"

docker run --rm -v "${PWD}:/root/workspace" ghcr.io/chgl/kube-powertools:v2.4.4@sha256:7fb936d1c8f04ea2e74b6de85cb742c093207009798aedb6f61fd6771e8919a5 /root/workspace/.github/renovate-bump-version.sh "${depName}" "${newVersion}"
