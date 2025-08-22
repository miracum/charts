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

docker run --rm -v "${PWD}:/root/workspace" ghcr.io/chgl/kube-powertools:v2.3.75@sha256:ecb187c8bb8fad55a02b3191f84a14090f611c94cde73730971e2406e2c83446 /root/workspace/.github/renovate-bump-version.sh "${depName}" "${newVersion}"
