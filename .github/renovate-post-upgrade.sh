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

docker run --rm -v "${PWD}:/root/workspace" ghcr.io/chgl/kube-powertools:v2.3.70@sha256:8bf2078f5519fd96872195cc051c473b03488067cfc750a842ac195ff0f64177 /root/workspace/.github/renovate-bump-version.sh "${depName}" "${newVersion}"
